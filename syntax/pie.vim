let main_syntax = 'pie'
if exists('b:current_syntax')
    finish
endif

syntax include @json syntax/json.vim

let b:current_syntax = 'pie'

syntax match pieHttpPath "[^ ]\+" contained
syntax match pieHttpHeaderValue "[^ ]\+" contained nextgroup=pieEnvValue skipnl
syntax match pieHttpHeaderKey "\v\w[^:]+:" contained nextgroup=pieHttpHeaderValue skipwhite

syntax keyword pieHttpVerb GET POST PATCH PUT HEAD DELETE nextgroup=pieHttpPath skipwhite

syntax match pieHttpTopLevel "^" nextgroup=pieHttpHeaderKey
syntax match pieEnv "^@\w\+:" nextgroup=pieEnvValue skipnl
syntax match pieEnvValue "^\s\+" contained nextgroup=pieHttpHeaderKey skipnl

syntax region pieJsonObjectBody start="{\@=" end="}\@=" contains=@json
syntax match pieComment "\v#.*$"

hi link pieComment Comment
hi link pieEnv Type

hi link pieHttpVerb Define
hi link pieHttpPath String
hi link pieHttpHeaderKey Label
hi link pieHttpHeaderValue Constant
