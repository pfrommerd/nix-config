let daniel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjasIJq1MDgp06wRwV1rfx+flR5BYwGZv2QumH2hyjA dan.pfrommer@gmail.com";
    kronos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBT0itfIyDXEZn4+1cQOo3tsEE0Y+bR1LBmVN35qZLMI";
    asahi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP0wHPdmH4Vx+lM1zztQgCfkq7vMHRYqTseh94Rk/eD";
    ececheira = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpobUqdNMifYci2q7GhuoNX3OIKHKcV4zaEN742A5mM";
    engaging = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMtcuWV9OVQL4MJPLETGu/uYd7HNewNQKPaeHEA/0oT";
    athena = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3jQRLk8lQbCDymI4NR/6gAhOeFkFM6XEmgx8iUSVCQ";
in {
   "daniel-passwd.age" = { publicKeys = [daniel kronos asahi ececheira ]; };
   "root-key.age" = { publicKeys = [daniel kronos asahi ececheira ]; };
   "root-crt.age" = { publicKeys = [daniel kronos asahi ececheira ]; };
   "daniel-hf-token.age" = { publicKeys = [ daniel kronos asahi engaging ececheira]; };
   "attic-netrc.age" = { publicKeys = [daniel kronos asahi ececheira athena]; };
}
