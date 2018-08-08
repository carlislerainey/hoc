data {
  int<lower=0> N;
  int<lower=0> K; 
  vector[N] y;
  matrix[N, K] X;
}

parameters {
  vector[K] beta;
  real<lower=0> sigma;
}

model {
  //beta ~ normal(0, 10);
  //sigma ~ cauchy(0, 5);
  y ~ normal(X * beta, sigma);
}

generated quantities {
  vector[N] y_rep;  // replicated data
  vector[N] log_lik;  // log likelihood
  // replicated data
  for (n in 1:N) {
    y_rep[n] = normal_rng(X[n] * beta, sigma);
  }
  // log likelihood
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | X[n] * beta, sigma);
  }
}
