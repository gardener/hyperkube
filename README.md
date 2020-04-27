# hyperkube

As part of [kubernetes/kubernetes#88676](https://github.com/kubernetes/kubernetes/pull/88676), the `hyperkube` image is be removed from the Kubernetes releases.
The first release not producing a `hyperkube` image anymore is v1.19.

This repository is used to produce a Docker image that contains the following Kubernetes binaries:

* kubelet
* kubectl

The rationale behind it is that Gardener requires those two binaries to present on each worker nodes of shoot clusters.
While it could simply download them from the internet for the clusters provisioned to hyperscalers, clusters provisioned to private/fenced environments do not necessarily have access to the internet.
However, the worker nodes will always have access to a image registry by design (otherwise, nothing will function at all).
Hence, the `hyperkube` image can be downloaded from the configured image registry and be used for copying over the binaries from the image to the host.

The image is as minimal as possible to only make the binaries portable.
It is not designed in a way to be used directly.

## How To Build It?

```shell
docker build --build-arg=KUBERNETES_VERSION=v1.18.2 .
```

## Limitations

Currently, there is no automatism that would build the images on new releases of Kubernetes.
The reasons are that the CI system does not support the requirements out-of-the-box yet for scripts in the `.ci` folder:

* No (easy) possibility to push branch or tags
* No (easy) possibility to build container images

Therefore, the following script must ran manually.
It will detect for which versions a new image must be built, build and push it, and push the Git tag.

Prerequisites:

* You must be eligible to `git push` tags to this repository.
* You must configure `gcloud` to authenticate with a valid GCP service account that allows pushing to the Gardener GCR.
  * `gcloud auth activate-service-account --key-file=<path-to-key-file>`
  * `gcloud auth configure-docker`

```shell
.ci/check-and-release
```

## Learn More!

Please find further resources about out project here:

* [Our landing page gardener.cloud](https://gardener.cloud/)
* ["Gardener, the Kubernetes Botanist" blog on kubernetes.io](https://kubernetes.io/blog/2018/05/17/gardener/)
* [SAP news article about "Project Gardener"](https://news.sap.com/2018/11/hasso-plattner-founders-award-finalist-profile-project-gardener/)
* [Introduction movie: "Gardener - Planting the Seeds of Success in the Cloud"](https://www.sap-tv.com/video/40962/gardener-planting-the-seeds-of-success-in-the-cloud)
* ["Thinking Cloud Native" talk at EclipseCon 2018](https://www.youtube.com/watch?v=bfw22WPg99A)
* [Blog - "Showcase of Gardener at OSCON 2018"](https://blogs.sap.com/2018/07/26/showcase-of-gardener-at-oscon/)
