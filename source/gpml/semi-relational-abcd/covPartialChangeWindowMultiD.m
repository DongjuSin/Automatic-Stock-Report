function K = covPartialChangeWindowMultiD(cov, hyp, x, z, i)
%COVPARTIALCHANGEWINDOWMULTID Summary of this function goes here
%   Detailed explanation goes here

if ~numel(cov) == 2, error('Partial change window contains a dimension and a covariance'), end

dim = cov{1};
cov = cov{2};
for ii = 1:numel(cov)                        
  f = cov(ii); if iscell(f{:}), f = f{:}; end   
  j(ii) = cellstr(feval(f{:}));
end

if nargin<3                                        
  K = ['3' '+' char(j(1))]; for ii=2:length(cov), K = [K, '+', char(j(ii))]; end, return
end

if nargin<4, z = []; end
original_z = z;
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;

if xeqz
    z = x;
end

v = [];               
for ii = 1:length(cov), v = [v repmat(ii, 1, eval(char(j(ii))))]; end

location = hyp(1);
steepness = exp(hyp(2));
width = exp(hyp(3));

tx1 = tanh((x(:,dim)-(location-0.5*width))*steepness);
tx2 = tanh(-(x(:,dim)-(location+0.5*width))*steepness);
ax = (0.5 + 0.5 * tx1) .* (0.5 + 0.5 * tx2);
if ~dg
    ax = repmat(ax, 1, length(z));
end
if ~dg
    tz1 = tanh((z(:,dim)-(location-0.5*width))*steepness);
    tz2 = tanh(-(z(:,dim)-(location+0.5*width))*steepness);
    az = (0.5 + 0.5 * tz1) .* (0.5 + 0.5 * tz2);
    az = repmat(az', length(x(:,dim)), 1);
else
    az = ax;
end

if nargin<5                                                        % covariances
  K = 0; if nargin==3, z = []; end                                 % set default
  for ii = 1:length(cov)                              % iteration over functions
    f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
%     if ii == 2
        K = K + ax .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* az;
%     else
%         K = K + (1-ax) .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (1-az);
%     end
  end
else                                                               % derivatives
  if i==1
    dx = -0.5*(1-tx1.^2).*steepness.*(0.5 + 0.5 * tx2) + ...
         0.5*(1-tx2.^2).*steepness.*(0.5 + 0.5 * tx1);
    dz = -0.5*(1-tz1.^2).*steepness.*(0.5 + 0.5 * tz2) + ...
         0.5*(1-tz2.^2).*steepness.*(0.5 + 0.5 * tz1);
    dx = repmat(dx, 1, length(z));
    dz = repmat(dz', length(x), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
%         if ii == 2
            K = K + dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* az;
            K = K + ax .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* dz;
%         else
%             K = K + -dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (1-az);
%             K = K + (1-ax) .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (-dz);
%         end
    end
  elseif i==2
    dx = +0.5*(1-tx1.^2).*(x(:,dim)-(location-0.5*width)).*steepness.*(0.5 + 0.5 * tx2) + ...
         0.5*(1-tx2.^2).*(-x(:,dim)+(location+0.5*width)).*steepness.*(0.5 + 0.5 * tx1);
    dz = +0.5*(1-tz1.^2).*(z(:,dim)-(location-0.5*width)).*steepness.*(0.5 + 0.5 * tz2) + ...
         0.5*(1-tz2.^2).*(-z(:,dim)+(location+0.5*width)).*steepness.*(0.5 + 0.5 * tz1);
    dx = repmat(dx, 1, length(z(:,dim)));
    dz = repmat(dz', length(x(:,dim)), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
%         if ii == 2
            K = K + dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* az;
            K = K + ax .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* dz;
%         else
%             K = K + -dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (1-az);
%             K = K + (1-ax) .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (-dz);
%         end
    end
  elseif i==3
    dx = 0.5*(1-tx1.^2).*0.5.*width.*steepness.*(0.5 + 0.5 * tx2) + ...
         0.5*(1-tx2.^2).*0.5.*width.*steepness.*(0.5 + 0.5 * tx1);
    dz = 0.5*(1-tz1.^2).*0.5.*width.*steepness.*(0.5 + 0.5 * tz2) + ...
         0.5*(1-tz2.^2).*0.5.*width.*steepness.*(0.5 + 0.5 * tz1);
    dx = repmat(dx, 1, length(z));
    dz = repmat(dz', length(x), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
%         if ii == 2
            K = K + dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* az;
            K = K + ax .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* dz;
%         else
%             K = K + -dx .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (1-az);
%             K = K + (1-ax) .* feval(f{:}, hyp([false false false (v==ii)]), x, original_z) .* (-dz);
%         end
    end
  elseif i<=length(v)+3
    i = i - 3;
    vi = v(i);                                       % which covariance function
    j = sum(v(1:i)==vi);                    % which parameter in that covariance
    f  = cov(vi);
    if iscell(f{:}), f = f{:}; end         % dereference cell array if necessary
    K = feval(f{:}, hyp([false false false (v==vi)]), x, original_z, j);                   % compute derivative
    if vi == 2
        K = ax .* K .* az;
    elseif vi == 1
        K = (1-ax) .* K .* (1-az);
    end
  else
    error('Unknown hyperparameter')
  end

end

