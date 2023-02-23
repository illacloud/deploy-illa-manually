#!/bin/bash


# deploy
kubectl apply -f ./illa-builder.yaml 

kubectl get deployments;
