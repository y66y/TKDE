function [ACC, OrderLp, path_out] = accuracy_my(Lt, Lp)
    % If Lp has more unique classes than Lt, swap them
    if length(unique(Lp)) > length(unique(Lt))
        a = Lp;
        Lp = Lt;
        Lt = a;
    end
    
    % Lt and Lp should not contain zeros
    % Lp should be sequential integers starting from 1 without any gaps
    C = length(Lt);
    
    % Adjust Lt to avoid zeros and ensure unique, sequential values
    ap = unique(Lt);
    Kpp = length(ap);
    Lt = Lt + C;
    
    for ki = 1:Kpp
        Lt(Lt == ap(ki) + C) = ki;
    end
    
    % Adjust Lp similarly
    ap = unique(Lp);
    Kpp = length(ap);
    Lp = Lp + C;
    
    for ki = 1:Kpp
        Lp(Lp == ap(ki) + C) = ki;
    end
    
    % Convert Lt and Lp to column vectors
    Lt = reshape(Lt, [], 1);
    Lp = reshape(Lp, [], 1);
    
    % Ensure Lt and Lp have the same length
    N = size(Lt, 1);
    if N ~= size(Lp, 1)
        ACC = [];
        return;
    end
    
    % Convert unique labels to 1, 2, 3, ...
    Ut = unique(Lt);
    Up = unique(Lp);
    Kt = length(Ut);
    Kp = length(Up);
    
    Lt_ = zeros(N, 1);
    Lp_ = zeros(N, 1);
    
    for ki = 1:Kt
        Lt_(Lt == Ut(ki)) = ki;
    end
    
    for ki = 1:Kp
        Lp_(Lp == Up(ki)) = ki;
    end
    
    % Create binary representation for class assignment
    Km = max(Kt, Kp);
    F_true = zeros(N, Km);
    F_pred = zeros(N, Km);
    
    for ni = 1:N
        F_true(ni, Lt_(ni)) = 1;
        F_pred(ni, Lp_(ni)) = 1;
    end
    
    % Compute confusion matrix and transpose for matching
    W = F_true' * F_pred;
    W = W';
    
    % Get optimal path for alignment
    path_out = pathSearch(W);
    
    if isempty(path_out)
        ACC = [];
        OrderLp = [];
        return;
    end
    
    % Create ordered labels based on optimal path
    OrderLp = zeros(N, 1);
    
    for ip = 1:Kp
        if ismember(path_out(ip), Ut)
            OrderLp(Lp == ip) = Ut(path_out(ip));
        else
            OrderLp(Lp == ip) = 0;
        end
    end
    
    % Calculate accuracy based on optimal path
    rate = 0;
    for ik = 1:Km
        rate = rate + W(ik, path_out(ik));
    end
    
    ACC = rate / N;

function [path_out] = pathSearch(W)
    % Obtain the size of the input matrix
    Kw = size(W, 1);
    
    % Convert the maximum values to minimum for optimal assignment
    W_min = max(max(W)) * ones(Kw, Kw) - W;
    
    % Find optimal path using assign2D function
    [path_out, ~, ~, ~, ~] = assign2D(W_min);
    
    % Transpose the output path for consistency
    path_out = path_out';
end

function [col4row, row4col, gain, u, v] = assign2D(C, maximize)
    if nargin < 2
        maximize = false;
    end

    % Get the dimensions of the cost matrix
    numRow = size(C, 1);
    numCol = size(C, 2);
    didFlip = false;

    % If the number of columns is greater than rows, flip the matrix
    if numCol > numRow
        C = C';
        temp = numRow;
        numRow = numCol;
        numCol = temp;
        didFlip = true;
    end

    % Ensure all elements in the cost matrix are positive for the assignment
    if maximize
        CDelta = max(max(C));
        C = -C + CDelta;
    else
        CDelta = min(min(C));
        C = C - CDelta;
    end
    
    % Initialize the assignment arrays
    col4row = zeros(numRow, 1);
    row4col = zeros(numCol, 1);
    u = zeros(numCol, 1); % Dual variable for columns
    v = zeros(numRow, 1); % Dual variable for rows
    
    % Find the shortest augmenting path for each column
    for curUnassCol = 1:numCol
        [sink, pred, u, v] = ShortestPath(curUnassCol, u, v, C, col4row, row4col);
        
        % If infeasible, return empty arrays
        if sink == 0
            col4row = [];
            row4col = [];
            gain = -1;
            return;
        end
        
        % Adjust assignments based on the path
        j = sink;
        while true
            i = pred(j);
            col4row(j) = i;
            [j, row4col(i)] = deal(row4col(i), j);
            if i == curUnassCol
                break;
            end
        end
    end
    
    % Calculate the gain for the optimal assignments
    if nargout > 2
        gain = 0;
        for curCol = 1:numCol
            gain = gain + C(row4col(curCol), curCol);
        end
        
        if maximize
            gain = -gain + CDelta * numCol;
        else
            gain = gain + CDelta * numCol;
        end
    end
    
    % Flip back if the matrix was flipped earlier
    if didFlip
        [row4col, col4row] = deal(col4row, row4col);
        [u, v] = deal(v, u);
    end
end

function [sink, pred, u, v] = ShortestPath(curUnassCol, u, v, C, col4row, row4col)
    % Initialize the scanned columns and rows
    numRow = size(C, 1);
    numCol = size(C, 2);
    pred = zeros(numCol, 1);

    % Track which columns and rows have been scanned
    ScannedCols = zeros(numCol, 1);
    ScannedRow = zeros(numRow, 1);
    Row2Scan = 1:numRow; % Columns left to scan
    numRow2Scan = numRow;
    sink = 0;
    delta = 0;
    curCol = curUnassCol;
    shortestPathCost = ones(numRow, 1) * inf;
    
    % Find the shortest augmenting path
    while sink == 0
        % Mark the current column as scanned
        ScannedCols(curCol) = 1;
        
        minVal = inf;
        
        for curRowScan = 1:numRow2Scan
            curRow = Row2Scan(curRowScan);
            
            % Calculate the reduced cost for the current column and row
            reducedCost = delta + C(curRow, curCol) - u(curCol) - v(curRow);
            
            if reducedCost < shortestPathCost(curRow)
                pred(curRow) = curCol;
                shortestPathCost(curRow) = reducedCost;
            end
            
            % Identify the minimum unassigned column
            if shortestPathCost(curRow) < minVal
                minVal = shortestPathCost(curRow);
                closestRowScan = curRowScan;
            end
        end
        
        % If no finite minimum value, the problem is infeasible
        if ~isfinite(minVal)
            sink = 0;
            return;
        end
        
        closestRow = Row2Scan(closestRowScan);
        
        % Mark the closest row as scanned
        ScannedRow(closestRow) = 1;
        numRow2Scan = numRow2Scan - 1;
        Row2Scan(closestRowScan) = [];
        
        delta = shortestPathCost(closestRow);
        
        % If the row is unassigned, set the sink
        if col4row(closestRow) == 0
            sink = closestRow;
        else
            curCol = col4row(closestRow);
        end
    end
    
    % Update the dual variables
    u(curUnassCol) = u(curUnassCol) + delta;
    
    sel = (ScannedCols ~= 0);
    sel(curUnassCol) = 0;
    
    u(sel) = u(sel) + delta - shortestPathCost(row4col(sel));
    sel = ScannedRow ~= 0;
    
    v(sel) = v(sel) - delta + shortestPathCost(sel);
end


end


