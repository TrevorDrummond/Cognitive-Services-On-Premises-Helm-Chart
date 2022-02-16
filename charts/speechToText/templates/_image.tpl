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
Create args that required by stt container
*/}}
{{- define "stt.image.args" -}}
{{- $eulaAllowedValues := list "accept" }}
{{- $eulaInput := .image.args.eula }}
{{- if not (has $eulaInput $eulaAllowedValues) }}
  {{- fail (printf "Unsupported eula: %s, must be {accept}" $eulaInput) }}
{{- end -}}
{{- if .textanalytics.enabled -}}
{{- $sentimentendpoint := printf "http://%s:%.0f/%s" "text-analytics" .textanalytics.service.port .textanalytics.service.sentimentURISuffix -}}
args: [{{- .image.args.eula | printf "eula=%s" | quote -}}, {{- required "missing required image.args.billing" .image.args.billing | printf "billing=%s" | quote -}}, {{- required "missing required image.args.apikey" .image.args.apikey | printf "apikey=%s" | quote -}}, {{- $sentimentendpoint | printf "CloudAI:SentimentAnalysisSettings:TextAnalyticsHost=%s" | quote -}}]
{{- else -}}
args: [{{- .image.args.eula | printf "eula=%s" | quote -}}, {{- required "missing required image.args.billing" .image.args.billing | printf "billing=%s" | quote -}}, {{- required "missing required image.args.apikey" .image.args.apikey | printf "apikey=%s" | quote -}}]
{{- end -}}
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
Calculate resources for container
*/}}
{{- define "stt.image.resources" -}}
{{- $_ := .  }}
{{- template "stt.CPU.calculate" $_ -}}
resources:
  requests:
    cpu: {{ $_.millicores }}m
    memory: "4Gi"
  limits:
    cpu: {{ $_.millicoresLimit }}m
    memory: "8Gi"
{{- end -}}

{{/*
Calculate resources for text analytics container
Each core must be > 2.6 GHz, TPS min/max: 15/30
*/}}
{{- define "textanalytics.image.resources" -}}
resources:
  requests:
    cpu: {{ .textanalytics.cpuRequest }}
    memory: {{ .textanalytics.memoryRequest | quote }}
  limits:
    cpu: {{ .textanalytics.cpuLimit }}
    memory: {{ .textanalytics.memoryLimit | quote }}
{{- end -}}

{{/*
Calculate environment values for container
*/}}
{{- define "stt.image.env" -}}
env:
  - name: DECODER_MAX_COUNT
    value: "{{ .numberOfConcurrentRequest }}"
{{- end -}}

{{- define "stt.CPU.calculate" -}}
{{- $_ := set . "millicores" (mul .numberOfConcurrentRequest 1250) }}
{{- if eq .optimizeForAudioFile true }}
    {{- $fr := dict "args" (list $_.millicores 17 10) }}
    {{- template "float.multi" $fr }}
    {{- $optimizedmillicores := $fr._return }}
    {{- $_ := set . "millicores" $optimizedmillicores }}
{{- end }}
{{- $millicoreslimit := mul $_.millicores 2 }}
{{- $_ := set . "millicoresLimit" $millicoreslimit }}
{{- end -}}

{{- define "float.multi" -}}
{{- /* template function to multiple float number and get the ceiling */}}
{{- /* sprig template only supports int64 multiple by default */}}
{{- /* args 0 and args 1 are numbers to multiple, args 2 is the floating faction */}}
{{- /* eg. to calculate 2.5 x 1.5, args 0 is 25, args 1 is 15, args2 is 100 */}}
{{- /* the final result will be applied ceil */}}
{{- $arg0 := index .args 0 }}
{{- $arg1 := index .args 1 }}
{{- $multiplier := index .args 2 }}

{{- $mult := mul $arg0 $arg1 }}
{{- $result := div $mult $multiplier }}
{{- if mod $mult $multiplier }}
    {{- $_ := set . "_return" (add1 $result) }}
{{- else }}
    {{- $_ := set . "_return" $result }}
{{- end }}
{{- end -}}