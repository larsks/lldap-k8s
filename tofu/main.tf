terraform {
  required_version = ">= 1.9.0"
  required_providers {
    lldap = {
      source = "tasansga/lldap"
    }
  }
}

variable "lldap_admin_password" {
  type      = string
  sensitive = true
}

provider "lldap" {
  http_url = "http://localhost:17170"
  ldap_url = "ldap://localhost:3890"
  username = "admin"
  password = var.lldap_admin_password
  base_dn  = "dc=example,dc=com"
}

resource "lldap_user_attribute" "ssh-key" {
  name           = "ssh-key"
  is_editable    = true
  attribute_type = "STRING"
}

resource "lldap_user_attribute" "wireguard-key" {
  name           = "wireguard-key"
  is_editable    = true
  is_list        = true
  attribute_type = "STRING"
}

resource "lldap_user" "authbot" {
  username     = "authbot"
  display_name = "Auth Bot"
  email        = "authbot@massopen.cloud"
}

resource "lldap_user" "larsks" {
  username     = "larsks"
  email        = "lars@redhat.com"
  display_name = "Lars Kellogg-Stedman"
  first_name   = "Lars"
  last_name    = "Kellogg-Stedman"
}

resource "lldap_user_attribute_assignment" "larsks-ssh-key" {
  user_id      = lldap_user.larsks.id
  attribute_id = lldap_user_attribute.ssh-key.id
  value        = [file("ssh-keys/larsks")]
}

resource "lldap_user_attribute_assignment" "larsks-wireguard-key" {
  user_id      = lldap_user.larsks.id
  attribute_id = lldap_user_attribute.wireguard-key.id
  value        = [file("wireguard-keys/larsks-home"), file("wireguard-keys/larsks-laptop")]
}

data "lldap_group" "lldap_strict_readonly" {
  id = 3
}

resource "lldap_user_memberships" "authbot" {
  user_id   = lldap_user.authbot.id
  group_ids = toset([data.lldap_group.lldap_strict_readonly.id])
}
