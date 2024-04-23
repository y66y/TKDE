clc
clear
close all
% Number of original images per person
num_images_per_person = 6;
% Size of each image
image_size = [192, 168];
% Number of persons
num_persons = 5;
% Number of samples per person
num_samples = 100;

% Initialize the final synthetic dataset
synthetic_data = zeros(prod(image_size), num_samples * num_persons);

% Loop through each person
for k = 1:num_persons
    [data, ~]=load_YaleBExtend_192_168(k,k); %2432
    % Randomly select six images from the Extended Yale-B dataset
    U_k=data(randperm(size(data,1), 6),:)';
    
    % U_k = zeros(prod(image_size), num_images_per_person);
    for j = 1:num_images_per_person
        % Create the basis matrix U_k
        % This assumes you have a way to load the specified image
        % For simplicity, use random images (you can replace with actual images)
        U_k(:, j) = rand(prod(image_size), 1);
    end

    % Generate 100 samples from the span of U_k
    X_k = zeros(prod(image_size), num_samples);
    for i = 1:num_samples
        % Generate random weights
        w_k_i = rand(num_images_per_person, 1);
        % Create synthetic sample
        X_k(:, i) = U_k * w_k_i;
    end

    % Add this to the final dataset
    synthetic_data(:, (k - 1) * num_samples + (1:num_samples)) = X_k;
end

% Normalize the synthetic data to the [0, 1] range
synthetic_data = (synthetic_data - min(synthetic_data(:))) / (max(synthetic_data(:)) - min(synthetic_data(:)));

% Generate additional datasets with Gaussian noise
noise_variances = [0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21];
noisy_datasets = cell(1, length(noise_variances));

for v = 1:length(noise_variances)
    noise_sigma = noise_variances(v);
    % Add Gaussian noise with zero mean and given variance
    noise = noise_sigma * randn(size(synthetic_data));
    noisy_data = synthetic_data + noise;
    % Clip to [0, 1] to keep within the normalized range
    noisy_data = max(min(noisy_data, 1), 0);
    noisy_datasets{v} = noisy_data;
end
L_true=[ones(100,1);ones(100,1)*2;ones(100,1)*3;ones(100,1)*4;ones(100,1)*5];
% Now 'synthetic_data' is the original dataset, and 'noisy_datasets' contain seven additional datasets with Gaussian noise.
%%

data=noisy_datasets{1};K=5;

lambda=0.2;W = graphConstruction(data, lambda);

delta=4;[W_order,order]=graphPermutation(W,delta);

[L_pred_]=graphSegmentation(W_order,K);L_pred(order)=L_pred_;

Acc=accuracy_my(L_true,L_pred)

