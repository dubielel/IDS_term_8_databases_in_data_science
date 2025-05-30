#!/bin/bash
echo "[INFO] Running mongorestore for north0..."
mongorestore --dir=/dump --nsInclude='north0.*'