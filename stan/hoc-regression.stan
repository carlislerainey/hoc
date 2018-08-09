data { 
  int N;  // number of observations total
  int K;  // number of explanatory variables
  int N_pos;  // number of positive observations
  int N_neg;  // number of positive observations
  vector[N] y;  // observed outcome
  int<lower=1, upper=3> y_dir[N];  // categorical outcomes (3 categories always)
  matrix[N, K] X;  // matrix of explanatory variables
  int<lower=1> y_pos_indicies[N_pos];
  int<lower=1> y_neg_indicies[N_neg];
}

transformed data {
  row_vector[K] zeros;
  vector[N_neg] y_neg_flipped;
  zeros = rep_row_vector(0, K);
  y_neg_flipped = -y[y_neg_indicies];
}

parameters {
  // model coefficients
  vector[K] beta_pos; 
  vector[K] beta_neg;
  vector[K] beta_pos_mag; 
  vector[K] beta_neg_mag;
  // scales
  real<lower=0> alpha_pos_mag;
  real<lower=0> alpha_neg_mag;
}

transformed parameters {
  matrix[N, 3] theta_dir;
  vector<lower=0>[N] sigma_pos_mag;
  vector<lower=0>[N] sigma_neg_mag;
  for (n in 1:N) {
    theta_dir[n, 1] = 0;
    theta_dir[n, 2] = X[n, ]*beta_neg;
    theta_dir[n, 3] = X[n, ]*beta_pos;
  }
  sigma_pos_mag = exp(X * beta_pos_mag);
  sigma_neg_mag = exp(X * beta_neg_mag);
}

model {
  // fixed effects
  beta_neg ~ cauchy(0, 1);
  beta_pos ~ cauchy(0, 1);
  beta_neg_mag ~ cauchy(0, 1);
  beta_pos_mag ~ cauchy(0, 1);
  alpha_neg_mag ~ cauchy(0, 1);
  alpha_pos_mag ~ cauchy(0, 1);
  // direction
  for (n in 1:N) {
    y_dir[n] ~ categorical_logit(theta_dir[n, ]');
  }
  // magnitude of increases
  for (n in 1:N_pos) {
    y[y_pos_indicies[n]] ~ weibull(alpha_pos_mag, sigma_pos_mag[y_pos_indicies[n]]);
  }
  // magnitude of decreases
  for (n in 1:N_neg) {
    y_neg_flipped[n] ~ weibull(alpha_neg_mag, sigma_neg_mag[y_neg_indicies[n]]);
  }
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_dir_rep;
  vector[N] y_neg_rep_flipped;
  vector[N] y_pos_rep;
  vector[N] y_rep;
  // y_rep
  for (n in 1:N) {
    y_dir_rep[n] = categorical_logit_rng(theta_dir[n, ]');
    y_neg_rep_flipped[n] = weibull_rng(alpha_neg_mag, sigma_neg_mag[n]);
    y_pos_rep[n] = weibull_rng(alpha_pos_mag, sigma_pos_mag[n]);
    if (y_dir_rep[n] == 1)
      y_rep[n] = 0;
    else if (y_dir_rep[n] == 2)
      y_rep[n] = -y_neg_rep_flipped[n]; 
    else if (y_dir_rep[n] == 3)
      y_rep[n] = y_pos_rep[n]; 
  }
  // log_lik
  for (n in 1:N) {
    if (y_dir[n] == 1) 
      log_lik[n] = log(softmax(theta_dir[n, ]')[1]);
    else if (y_dir[n] == 2)
      log_lik[n] = log(softmax(theta_dir[n, ]')[2]) + weibull_lpdf(-y[n] | alpha_neg_mag, sigma_neg_mag[n]); 
    else if (y_dir[n] == 3)
      log_lik[n] = log(softmax(theta_dir[n, ]')[3]) + weibull_lpdf(y[n] | alpha_pos_mag, sigma_pos_mag[n]); 
  }
}

  // log likelihood
//  for (n in 1:N) {
//    log_lik[n] = normal_lpdf(y[n] | X[n] * beta, sigma);
//  }
