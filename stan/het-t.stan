data {
  int<lower=0> N;
  int<lower=0> K; 
  vector[N] y;
  matrix[N, K] X;
}

parameters {
  vector[K] beta;
  vector[K] gamma;
  real<lower=1> nu;
}

transformed parameters {
  vector[N] mu; // location parameter
  vector[N] sigma; // scale
  mu = X * beta;
  sigma = exp(X * gamma);
}

model {
  //beta ~ normal(0, 10);
  //sigma ~ cauchy(0, 5);
  nu ~ gamma(2, 0.1);
  y ~ student_t(nu, mu, sigma);
}

generated quantities {
  vector[N] y_rep;  // replicated data
  vector[N] log_lik;  // log likelihood
  // replicated data
  for (n in 1:N) {
    y_rep[n] = student_t_rng(nu, mu[n], sigma[n]);
  }
  // log likelihood
  for (n in 1:N) {
    log_lik[n] = student_t_lpdf(y[n] | nu, mu[n], sigma[n]);
  }
}
