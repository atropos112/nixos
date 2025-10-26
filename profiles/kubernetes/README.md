# Kubernetes Configuration Notes

## Changing IP that kubectl communicates with

Suppose you want to change the IP to which you call for Kubernetes API.

Typically using `.kubeconfig` you have a cert and when making the call it includes what IP you actually called (even if proxied) as a result if you change ip there even if it somehow points to your Kubernetes API if its not on the list of approved IP's its not going to work.
To fix that you will have to pass different IP as input into k3s server, this can be done by either editing systemd service (on master nodes only) or edit `config.yaml` if that is what you are using.

You can either pass `--tls-san <new-ip-here>` into argument or add `tls-san: "<new-ip-here>"` line in k3s config.yaml.

After starting k3s with this new setting on all master nodes you then have to SSH onto each master node and execute

```bash
curl -vk --resolve <new-ip-here>:6443:127.0.0.1  https://<new-ip-here>:6443/ping
```

I am not sure why the above is necessary, but without it, it might still hold onto old one. I suspect it clears out some cache.
