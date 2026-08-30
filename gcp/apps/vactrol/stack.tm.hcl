stack {
  name        = "vactrol Cloud Run"
  description = "Vactrol browser client (Go + WebAssembly) at vactrol.mklv.tech"
  id          = "gcp-apps-vactrol"
  tags        = ["google", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
  ]
}
