fuel-plugin-detach-haproxy
==========================

## Purpose
The main purpose of this plugin is to provide ability to deploy Load Balancer
(Haproxy) separately from controllers.

## Compatibility

| Plugin version | Branch        | Fuel version |
| -------------- | ------------- | ------------ |
| 1.x.x          | stable/8.0    | Fuel-8.x     |
| 2.x.x          | stable/mitaka | Fuel-9.x     |

## How to build plugin

* Install fuel plugin builder (fpb)
* Clone plugin repo and run fpb there:
```
git clone https://github.com/openstack/fuel-plugin-detach-haproxy
cd fuel-plugin-detach-haproxy
fpb --build .
```
* Check if file `detach_haproxy-*.noarch.rpm` was created.

## Known limitations
* OSTF is not working

## Configuration

No need to configure plugin. Just assign `Haproxy` roles to needed nodes.
If you're using it along with [External Load Balancer](https://github.com/openstack/fuel-plugin-external-lb)
plugin for testing purposes, you also don't need to configure External Load
Balancer plugin, it will be configured to use Haproxy nodes automaticaly.
