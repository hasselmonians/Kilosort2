function setConfig(filename, varargin)

  % generates a configuration file using the specified options
  % and places it in target location
  %
  % setConfig()
  %
  % setConfig(filename)
  %
  % setConfig(filename, 'PropertyName', 'PropertyValue', ...)
  %
  % Arguments
  %
  %
  %
  %
  %
  %
  %
  %
  %



  %% Default options

  ops                     = struct;

  % path to the channel map .mat file
  ops.chanMap             = [];

  % path to raw data (including binary)
  ops.dataPath            = [];

  % path to the .dat file
  ops.fproc               = [];

  % time range to sort
  ops.trange              = [0, Inf];

  % total number of channels in your recording
  ops.nChan               = 384;

  % sample rate
  ops.fs                  = 30000;

  % frequency for high pass filtering (150)
  ops.fshigh              = 150;

  % minimum firing rate on a "good" channel (0 to skip)
  ops.minfr_goodchannels  = 0.1;

  % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
  ops.Th                  = [10 4];

  % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot)
  ops.lam                 = 10;

  % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
  ops.AUCsplit            = 0.9;

  % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
  ops.minFR               = 1/50;

  % number of samples to average over (annealed from first to second value)
  ops.momentum            = [20 400];

  % spatial constant in um for computing residual variance of spike
  ops.sigmaMask           = 30;

  % threshold crossings for pre-clustering (in PCA projection space)
  ops.ThPre               = 8;

  %% danger, changing these settings can lead to fatal errors

  % options for determining PCs
  ops.spkTh               = -6;     % spike threshold in standard deviations (-6)
  ops.reorder             = 1;      % whether to reorder batches for drift correction.
  ops.nskip               = 25;     % how many batches to skip for determining spike PCs

  ops.GPU                 = 1;      % has to be 1, no CPU version yet, sorry
  % ops.Nfilt               = 1024; % max number of clusters
  ops.nfilt_factor        = 4;      % max number of clusters per good channel (even temporary ones)
  ops.ntbuff              = 64;     % samples of symmetrical buffer for whitening and spike detection
  ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory).
  ops.whiteningRange      = 32;     % number of channels to use for whitening each channel
  ops.nSkipCov            = 25;     % compute whitening matrix from every N-th batch
  ops.scaleproc           = 200;    % int16 scaling of whitened data
  ops.nPCs                = 3;      % how many PCs to project the spikes into
  ops.useRAM              = 0;      % not yet available

  % print options if no arguments are given
  if nargin == 0
    disp('The allowed options are:')
    disp(fieldnames(ops))
  end

  % validate and accept options
  if mathlib.iseven(length(varargin))
    for ii = 1:2:length(varargin)-1
      temp = varargin{ii}
      if ischar(temp)
        if ~any(find(strcmp(temp, fieldnames(ops))))
          disp(['Unknown option: ' temp])
          disp('The allowed options are:')
          disp(fieldnames(ops))
          error('UNKNOWN OPTION')
        end
      else
        ops.(temp) = varargin{ii+1};
      end
    end
  elseif isstruct(varargin{1})
    % assume it's an ops struct
    ops = varargin{1};
  else
    error('Inputs need to be name-value pairs')
  end

  %% Post-processing

  if isempty(ops.chanMap)
    ops.chanMap = 1:ops.Nchan; % treated as linear probe if no chanMap file
  end

  % save options to filename
  save(filename, ops);

end % function
