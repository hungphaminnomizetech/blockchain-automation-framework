disable_mlock = true
ui            = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

storage "file" {
  path = "/home/tiennguyen/projects/hyperledger/blockchain-automation-framework/vault_data"
}
