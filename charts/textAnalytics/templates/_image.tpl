{{/*
Create full container image name by either hash or tag. It requires specific layout within the container scope
*/}}
{{- define "image.full" -}}
{{- if .pullByHash }}
{{- printf "%s/%s@sha256:%s" .registry .repository .hash -}}
{{- else }}
{{- printf "%s/%s:%s" .registry .repository .tag -}}
{{- end }}
{{- end -}}

{{/*
Create a pull policy based on whether we pull by hash or tag
*/}}
{{- define "image.pull" -}}
{{- if .pullByHash -}}IfNotPresent{{- else -}}Always{{- end -}}
{{- end -}}


{{/*
Create args that required by general container
*/}}
{{- define "image.args" -}}
{{- $eulaAllowedValues := list "accept" }}
{{- $eulaInput := .eula }}
{{- if not (has $eulaInput $eulaAllowedValues) }}
  {{- fail (printf "Unsupported eula: %s, must be {accept}" $eulaInput) }}
{{- end -}}
args: [{{- .eula | printf "eula=%s" | quote -}}, {{- required "missing required image.args.billing" .billing | printf "billing=%s" | quote -}}, {{- required "missing required image.args.apikey" .apikey | printf "apikey=%s" | quote -}}]
{{- end -}}

{{/*
Create image pull secret(s) for container
*/}}
{{- define "image.secrets" -}}
    {{- range $key :=. -}}
        - name: {{ $key }}
    {{- end -}}
{{- end -}}


{{/*
Calculate resources for text analytics container
Each core must be > 2.6 GHz, TPS min/max: 15/30
*/}}
{{- define "image.resources" -}}
resources:
  requests:
    cpu: {{ .cpuRequest }}
    memory: {{ .memoryRequest | quote }}
  limits:
    cpu: {{ .cpuLimit }}
    memory: {{ .memoryLimit | quote }}
{{- end -}}
