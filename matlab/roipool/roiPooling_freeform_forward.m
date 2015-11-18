function[rois, masks] = roiPooling_freeform_forward(rois, masks, blobMasks, combineFgBox)
% [rois, masks] = roiPooling_freeform_forward(rois, masks, blobMasks, combineFgBox)
%
% Freeform pooling forward pass.
%
% This is an extension to the roiPool layer and MUST come after it in a
% network. It applies a each blob's freeform mask to the activations and
% masks of roi pooling.
%
% Depending on the options, it either keeps the entire box, just the
% foreground or both.
%
% Copyright by Holger Caesar, 2015

% Perform freeform pooling
% Store a copy of the box features if we still need them
if combineFgBox,
    roisBox = rois;
    masksBox = masks;
end;

% Move inputs from GPU if necessary
onGpu = isa(rois, 'gpuArray');
if onGpu,
    rois = gather(rois);
end;

assert(numel(blobMasks) == size(rois, 4));
for blobIdx = 1 : numel(blobMasks),
    % Determine background mask
    [rois(:, :, :, blobIdx), masks(:, :, :, blobIdx)] = roiPooling_freeform_blob(blobMasks{blobIdx}, rois(:, :, :, blobIdx), masks(:, :, :, blobIdx));
    
    % Debug: To visualize each blob
    % figure(1); imagesc(blobMaskOri); figure(2); imagesc(blobMask); nonEmptyChannel = maxInd(squeeze(sum(sum(rois(:, :, :, blobIdx), 1), 2))); figure(3); imagesc(rois(:, :, nonEmptyChannel, blobIdx)); figure(4); imagesc(masks(:, :, nonEmptyChannel, blobIdx))
end;

% Move outputs to GPU if necessary
if onGpu,
    rois = gpuArray(rois);
end;

% Concatenate fg and box
if combineFgBox,
    rois  = cat(3, rois, roisBox);
    masks = cat(3, masks, masksBox);
end;