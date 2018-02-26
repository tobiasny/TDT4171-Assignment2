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

% Filtering using forward-algorithm
for i = 1:length(evidence)
    if evidence(i) == 1
        x = forward(T,O_true,x);
    else
        x = forward(T,O_false,x);
    end
end

fprintf('Evidence <%i,%i>, Probability of rain: %f\n',evidence,x(1));

%% Probability of rain at day 5 (given observation sequence in exercise description)

%Observation sequence
evidence = [1 1 0 1 1];

%Probability distribution
X = zeros(2, length(evidence)+1);
X(:,1) = x0;

% Filtering using forward-algorithm
for i = 1:length(evidence)
    if evidence(i) == 1
        X(:,i+1) = forward(T,O_true,X(:,i));
    else
        X(:,i+1) = forward(T,O_false,X(:,i));
    end
    
    fprintf('f%i = <%f, %f>\n',i,X(1,i),X(2,i));
end

fprintf('Probability after forwarding: X=\n')
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




