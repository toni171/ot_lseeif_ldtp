%% PARAMETERS.

%----- MAIN PARAMETERS.
% The images in the dataset are numbered from 1 to 17.
img_idx = 14;    % Image to segment.

% The mask for the segmentation can be generated using the Otsu's technique
% or the adaptive technique.
otsu_tech = false;   % It will use Otsu if true, adaptive if false.

display_set = true;     % It will show the segmentation process if true.
display_every = 10;     % Iterations between two shown set.

display_metrics = true; % It will show the evaluation metrics if true.

%----- OTHER PARAMETERS.
% Preprocessing parameters
% Images, labels and functions folders paths.
img_folder = "dataset\images";
label_folder = "dataset\labels";
funct_folder = "functions";
% CLAHE parameters.
num_tiles = [8 8];
clip_limit = 0.2;
sensitivity = 0.8;      % Sensitivity for adaptive thresholding.
% Noise removal parameters.
noise_area = 50;        % Smaller noisy regions are removed.
conn = 4;               % Connectivity for regions identification.
sigma = 1.2;            % Standard deviation of Gaussian filtering.

% Segmentation paramters.
n_iters  = 599;         % Number of iterations.
eps_h = 1.0;
lambda_1 = 1.0;         % Weighting parameters for data force computation.
lambda_2 = 1.0;
alpha = 0.2;            % Weight for smoothing force.
beta = 1.0;             % Weight for edge attraction force.
mu_ldtp = 0.0;          % Weight for LDTP-based force.
dt = 0.5;               % Time step.
reinit_int = 50;        % Iterations between two reinitializations.
reinit_dt = 0.5;        % Time step for Sussman reinitialization.
reinit_iters = 10;      % Iterations for Sussman reinitialization.
min_area = 2400;        % Minimum area of the tumor.
expand_radius = 14;     % Radius of disk to expand the labeled mask.
smt_disk = 10;          % Radius for smoothing of label mask.
pixel_spacing = 1.0;    % Pixel spacing for metrics computation.
n_samples = 1000;       % Segmented region points to take into account. 


%% DATA READING.

% Import paths of images and labels.
addpath(img_folder)
addpath(label_folder)
addpath(funct_folder)

% Produces paths of image and label.
img_path = strcat(int2str(img_idx), ".jpg");
label_path = strcat(int2str(img_idx), ".json");

% Reads the image.
init_img = imread(img_path);

% Reads the label.
label = fileread(label_path);
label = jsondecode(label);

% Converts the initial image to grayscale (if needed).
if size(init_img, 3) == 3
    init_img = rgb2gray(init_img);
end

%% PREPROCESSING.

% Performs the image preprocessing and computes the binary mask.
[img, mask] = preprocessing(init_img, num_tiles, clip_limit, ...
    otsu_tech, sensitivity, noise_area, conn);

%% LEVEL SET EVOLUTION

% Performs the Level Set Evolution and returns the mask of possible
% eligible tumor regions and the structure array of diagnostic metrics.
[regions_mask, diagnostics] = level_set_evolution(img, mask, sigma, ...
    n_iters, eps_h, lambda_1, lambda_2, alpha, beta, mu_ldtp, dt, ...
    reinit_int, reinit_dt, reinit_iters, display_set, display_every, ...
    noise_area);

% Shows cleaned mask.
figure, imshow(regions_mask), title("Eligible Tumor Regions.")

%% TUMOR IDENTIFICATION

% Detects the tumor region between the eligible ones and returns the table
% of regions stats and the index of tumor region.
[tumor_mask, tumor_idx, region_stats] = tumor_identification(...
    regions_mask, min_area, expand_radius);

%% METRICS COMPUTATION

% Creates the mask of the true tumor region based on labeled border points.
[label_mask] = label_mask_creation(label, img, smt_disk);

[metrics_table, seg_boundary_pts, label_boundary_pts] = ...
    compute_metrics(tumor_mask, label_mask, label, pixel_spacing, n_samples);

%% RESULTS

if display_metrics
    % Displays metrics on command window.
    fprintf('Segmentation evaluation\n');
    disp(metrics_table);

    % Displays metrics in a figure.
    f = figure('Name', 'Evaluation Metrics', ...
        'NumberTitle', 'off', 'Color', 'w', 'Units', 'normalized', ...
        'Position', [0.7 0.2 0.25 0.4]);
    uitable(f, ...
        'Data', table2cell(metrics_table), ...
        'ColumnName', metrics_table.Properties.VariableNames, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1]);
end

display_segmentation(init_img, seg_boundary_pts, label_boundary_pts, ...
    region_stats, tumor_idx, tumor_mask)