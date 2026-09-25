stack {
  name        = "vex Cloud Run"
  description = "Vex browser client (Go + WebAssembly) at vex.mklv.tech"
  id          = "gcp-apps-vex"
  tags        = ["google", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
  ]
}
