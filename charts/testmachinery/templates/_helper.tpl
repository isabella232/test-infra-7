# Copyright 2019 Copyright (c) 2019 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{- define "defaultLabels" -}}
app.kubernetes.io/name: testmachinery
helm.sh/chart: testmachinery
app.kubernetes.io/instance: {{ .Release.Name }}
app: testmachinery-controller
{{- end -}}

{{- define "config" -}}
---
apiVersion: config.testmachinery.gardener.cloud/v1beta1
kind: Configuration
controller:
  healthAddr: ":{{ .Values.controller.healthEndpointPort }}"
  metricsAddr: ":{{ .Values.controller.metricsEndpointPort }}"
  enableLeaderElection: {{ .Values.controller.enableLeaderElection }}
  maxConcurrentSyncs: {{ .Values.controller.maxConcurrentSyncs }}
  webhook:
    port: {{ .Values.controller.webhook.port }}
    certDir: /etc/testmachinery-controller/srv
  dependencyHealthCheck:
    namespace: {{ .Release.Namespace }}
    deploymentName: {{ .Values.argo.argo.name }}
    interval: {{ .Values.controller.argoHealthCheckInterval }}

testmachinery:
  namespace: {{ .Release.Namespace }}
  testdefPath: {{ .Values.testmachinery.testdefPath }}
  local: {{ .Values.testmachinery.local }}
  insecure: {{ .Values.testmachinery.insecure }}
  disableCollector: {{ .Values.testmachinery.disableCollector }}
  cleanWorkflowPods: {{ .Values.testmachinery.cleanWorkflowPods }}

  {{- if .Values.testmachinery.locations }}
  locations:
{{ toYaml .Values.testmachinery.locations | indent 4 }}
  {{- end }}

  {{- if .Values.testmachinery.landscapeMappings }}
  landscapeMappings:
  {{- toYaml .Values.testmachinery.landscapeMappings | nindent 4 }}
  {{- end }}

github:
  cache:
    cacheDir: {{ .Values.testmachinery.github.cache.cacheDir }}
    cacheDiskSizeGB: {{ .Values.testmachinery.github.cache.cacheDiskSizeGB }}
    maxAgeSeconds: {{ .Values.testmachinery.github.cache.maxAgeSeconds }}
  {{- if .Values.testmachinery.github.credentials }}
  secretsPath: /etc/testmachinery-controller/secrets/git/github-secrets.yaml # mount secrets and specify the path
  {{- end }}

s3Configuration:
  server:
    endpoint: {{ required "Missing an entry for .Values.global.s3Configuration.server.endpoint!" .Values.global.s3Configuration.server.endpoint }}
    ssl: {{ required "Missing an entry for .Values.global.s3Configuration.server.ssl!" .Values.global.s3Configuration.server.ssl }}
  bucketName: {{ required "Missing an entry for .Values.global.s3Configuration.bucketName!" .Values.global.s3Configuration.bucketName }}
  accessKey: {{ required "Missing an entry for Values.global.s3Configuration.accessKey!" .Values.global.s3Configuration.accessKey }}
  secretKey: {{ required "Missing an entry for .Values.global.s3Configuration.secretKey!" .Values.global.s3Configuration.secretKey }}

{{- if .Values.testmachinery.esConfiguration }}
esConfiguration:
{{ toYaml .Values.testmachinery.esConfiguration | indent 2 }}
{{- end }}

{{- if .Values.testmachinery.imagePullSecrets }}
imagePullSecretNames:
  {{- range .Values.testmachinery.imagePullSecrets }}
  - {{.name}}
  {{- end }}
{{- end }}

{{- end }}