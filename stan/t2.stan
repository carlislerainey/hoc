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
  beta ~ normal(0, 10);
  sigma ~ cauchy(0, 10);
  y ~ student_t(2, X * beta, sigma);
}

generated quantities {
  vector[N] y_rep;  // replicated data
  vector[N] log_lik;  // log likelihood
  // replicated data
  for (n in 1:N) {
    y_rep[n] = student_t_rng(2, X[n] * beta, sigma);
  }
  // log likelihood
  for (n in 1:N) {
    log_lik[n] = student_t_lpdf(y[n] | 2, X[n] * beta, sigma);
  }
}
