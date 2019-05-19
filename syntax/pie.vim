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
syntax match pieEnv "^@\h\w\+:" nextgroup=pieEnvValue skipnl
syntax match pieEnvValue "^\s\+" nextgroup=pieHttpHeaderKey,pieVarAssignment skipnl

syntax match pieVarIdentifier "$\h\w\+" nextgroup=pieVarAssignment skipwhite
syntax match pieVarAssignment "=" contained nextgroup=jsonString,pieNumber skipwhite
syntax match pieNumber "[1-9]\d*" contained

syntax region pieJsonObjectBody start="{\@=" end="}\@<=" contains=@json

syntax match pieComment "\v#.*$"

hi default link pieComment Comment
hi default link pieEnv Type

hi default link pieVarIdentifier Identifier
hi default link pieNumber Number

hi default link pieHttpVerb Define
hi default link pieHttpPath String
hi default link pieHttpHeaderKey Label
hi default link pieHttpHeaderValue Constant
