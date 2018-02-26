%% Init
clc
clear all

% Dynamic Model
T = [0.7 0.3;
     0.3 0.7];
 
%Observation Model
%Model when E = true
O_true = [0.9 0;
          0 0.2];
%Model when E = false
O_false = [0.1 0;
           0 0.8];

% Initial value - chance of rain (no prior knowledge)
x0 = [0.5;0.5];

%% Probability of rain at day 2 (Verification of algorithm)

% Umbrella used on day 1 and 2
evidence = [1 1];
% Initialize state value
x = x0;

% Filterning using forward-algorithm 
for i = 1:length(evidence)
    if evidence(i) == 1
        x = forward(T,O_true,x);
    else
        x = forward(T,O_false,x);
    end
end

fprintf('Probability after forwarding: %f\n',x(1));

%Initial backward message
b = [1;1];

% Smoothing using backward-algorithm
for i = length(evidence):-1:1
    x = normalize(x.*b);
    fprintf('Backwards message: <%f,%f> \n',b(1),b(2));
    if evidence(i) == 1
        b = backward(T,O_true,b);
    else
        b = backward(T,O_false,b);
    end
end

fprintf('Probability after backwarding: %f\n',x(1));

%% Probability of rain at day 5 (given observation sequence in exercise description)

% Observation sequence
evidence = [1 1 0 1 1];

% Probability distribution
X = zeros(2,length(evidence)+1);
X(:,1) = x0;

% Filtering using forward-algorithm
for i = 1:length(evidence)
    if evidence(i) == 1
        X(:,i+1) = forward(T,O_true,X(:,i));
    else 
        X(:,i+1) = forward(T,O_false,X(:,i));
    end
end

fprintf('Probability after forwarding: X=\n');
disp(X)

% Initial backward message
b = [1;1];

% Smoothing using backward-algorithm
for i = length(evidence):-1:1
    X(:,i+1) = normalize(X(:,i+1).*b);
    fprintf('Backwards message: <%f,%f> \n',b(1),b(2));
    if evidence(i) == 1
        b = backward(T,O_true,b);
    else
        b = backward(T,O_false,b);
    end
end

fprintf('Probability after smoothing: X=\n')
disp(X)

%% Functions

% Normalizing matrix/vector
function alpha = normalize(matrix)
   alpha = matrix./sum(sum(matrix)); 
end

% Forward algorithm as described in Russel & Norvig
function x = forward(T,O,fprev)
    x = normalize(O*T'*fprev);
end

% Backward algorithm as described in Russel & Norvig
function b = backward(T,O,bnext)
    b = T*O*bnext;
end