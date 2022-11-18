#!/bin/bash


# deploy
kubectl apply -f ./illa-database.yaml 
kubectl apply -f ./illa-frontend.yaml 
kubectl apply -f ./illa-backend.yaml
kubectl apply -f ./illa-backend-ws.yaml

kubectl get deployments;
