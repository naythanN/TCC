# TCC

### English

This repository contains my graduation project.

This project is a prototype of a cloud gaming service based on Sunshine and Moonlight.

I used sunshine docker image and customized it to run on Kubernetes. It was tested on AWS EKS.

A key difference in this project is the use of Nvidia MPS to run multiple games in the same GPU, using less resources than other approaches.

### Português

Este repositório contém meu projeto final de graduação.

Este projeto é um protótipo de um servico de cloud gaming baseado no Sunshine e no Moonlight.

Eu usei as imagens docker do Sunshine e as customizei para rodar no Kubernetes. Foi testado no AWS EKS.

A principal diferença deste projeto em relação aos semelhantes é o uso do Nvidia MPS para rodar vários jogos na mesma GPU, usando então, menos recursos.


## Use

Here there are some instructions to run the project (although there are scripts to do it, it could be automated more).

There are two directories in the repository. game_builds and infra.
The game_builds contain Dockerfiles to build the images. The infra contains the definitions of the infrastructure. To create the infrastructure you need to have access to an AWS account that is able to create EC2 instances with GPUs. After configuring the AWS credentials, you need to install eksctl, kubectl, aws-cli to run the scripts.

The script infra_setup.sh contains the necessary steps to set up the infrastructure, but there are manual steps commented in the script that are necessary for the moment.

It is also possible to run this locally, although Nvidia MPS won't work on consumer GPUs since it is a datacenter technology only.





