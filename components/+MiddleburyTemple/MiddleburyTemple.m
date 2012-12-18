classdef MiddleburyTemple < MiddleburyTemple.MiddleburyTempleConfig & hidi.DataContainer

  properties (GetAccess = private, SetAccess = private)
    sensor
    sensorDescription
    bodyRef
    hasRef
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      function text = componentDescription
        text = ['Image data from the Middlebury Temple dataset with a configurable reference trajectory ',...
          'constructed from ground truth. The object is a plaster reproduction of "Temple of the Dioskouroi" in ',...
          'Agrigento, Sicily. Reference: A Comparison and Evaluation of Multi-View Stereo Reconstruction ',...
          'Algorithms, CVPR 2006, vol. 1, pages 519-526.'];
      end
      hidi.DataContainer.connect(name, @componentDescription, @MiddleburyTemple.MiddleburyTemple);
    end

    function this = MiddleburyTemple(initialTime)
      this = this@hidi.DataContainer(initialTime);
      
      % download data set
      localDir = fileparts(mfilename('fullpath'));
      localCache = fullfile(localDir, this.dataSetName);
      if(~exist(localCache, 'dir'))
        zipName = [this.dataSetName, '.zip'];
        localZip = [localDir, '/', zipName];
        url = [this.repository, zipName];
        if(this.verbose)
          fprintf('\ncaching: %s', url);
        end
        urlwrite(url, localZip);
        if(this.verbose)
          fprintf('\nunzipping: %s', localZip);
        end
        unzip(localZip, localDir);
        delete(localZip);
      end
      this.sensor{1} = MiddleburyTemple.CameraSim(initialTime);
      this.sensorDescription{1} = 'Forward facing monocular perspective camera fixed at the body origin';
      [t, p, q, r, s] = this.readTempleParameterFile(initialTime);
      this.bodyRef = MiddleburyTemple.ReferenceTrajectory(t, p, q, r, s);
      this.hasRef = true;
    end
  end
  
  methods (Access = public)
    function list = listSensors(this, type)
      K = numel(this.sensor);
      flag = false(K, 1);
      for k = 1:K
        if(isa(this.sensor{k}, type))
          flag(k) = true;
        end
      end
      list = hidi.SensorIndex(find(flag)-1);
    end
    
    function text = getSensorDescription(this, id)
      text = this.sensorDescription{id+1};
    end
        
    function obj = getSensor(this, id)
      obj = this.sensor{id+1};
    end
    
    function flag = hasReferenceTrajectory(this)
      flag = this.hasRef;
    end
    
    function x = getReferenceTrajectory(this)
      x = this.bodyRef;
    end
  end
  
  methods (Access = private)
    function [t, p, q, r, s] = readTempleParameterFile(this, initialTime)
      K = numel(this.poseList);
      t = initialTime+(0:(K-1))/this.fps;
      p = zeros(3, K);
      q = zeros(4, K);
      r = zeros(3, K);
      s = zeros(3, K);
      filename = fullfile(fileparts(mfilename('fullpath')), this.dataSetName, [this.fileStub, '_par.txt']);
      fid = fopen(filename, 'rt');
      N = str2double(fgetl(fid));
      data = zeros(N, 22);
      format = [this.fileStub, '%04d.png %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'];
      for n = 1:N
        str = fgetl(fid);
        data(n, :) = sscanf(str, format);
      end
      for k = 1:K
        kk = find(data(:, 1)==this.poseList(k), 1, 'first');
        if(isempty(kk))
          error('requested pose index (%d) not found in file (%s)', k, filename);
        end
        Rinv = reshape(data(kk, 11:19), [3, 3]);
        T = data(kk, 20:22)';
        p(:, k) = Rinv*T;
        % Convert from left-down-backward to forward-right-down
        Rinv = [-Rinv(:, 3), -Rinv(:, 1), Rinv(:, 2)];
        q(:, k) = Euler2Quat(Matrix2Euler(Rinv));
        frewind(fid);
        fgetl(fid);
      end
      fclose(fid);
      p = this.scale*p;
      p(1, :) = p(1, :)+tom.WGS84.majorRadius;
    end
  end
  
end

function Y = Matrix2Euler(R)
  Y = zeros(3, 1); 
  Y(1) = atan2(R(3, 2), R(3, 3));
  Y(2) = asin(-R(3, 1));
  Y(3) = atan2(R(2, 1), R(1, 1));
end

function Q = Euler2Quat(E)
  a = E(1, :);
  b = E(2, :);
  c = E(3, :);
  c1 = cos(a/2);
  c2 = cos(b/2);
  c3 = cos(c/2);
  s1 = sin(a/2);
  s2 = sin(b/2);
  s3 = sin(c/2);
  Q(1, :) = c3.*c2.*c1 + s3.*s2.*s1;
  Q(2, :) = c3.*c2.*s1 - s3.*s2.*c1;
  Q(3, :) = c3.*s2.*c1 + s3.*c2.*s1;
  Q(4, :) = s3.*c2.*c1 - c3.*s2.*s1;
end
