let main_syntax = 'pie'
if exists('b:current_syntax')
    finish
endif

syntax include @json syntax/json.vim
syntax include @javascript syntax/javascript.vim

let b:current_syntax = 'pie'

syntax match pieHttpPath "[^ ]\+" contained nextgroup=pieProcessorPipe skipwhite
syntax match pieHttpHeaderValue "[^ ]\+" contained nextgroup=pieEnvValue skipnl
syntax match pieHttpHeaderKey "\v\w[^:]+:" contained nextgroup=pieHttpHeaderValue skipwhite

syntax keyword pieHttpVerb GET POST PATCH PUT HEAD DELETE nextgroup=pieHttpPath skipwhite

syntax keyword pieProcessorPipe "\|" contained nextgroup=pieProcessorId skipwhite
syntax match pieProcessorId "\h\w\+"  contained skipwhite

syntax keyword pieProcessorVerb PROCESSOR nextgroup=pieProcessorIdentifier skipwhite
syntax match pieProcessorIdentifier "\h\w\+" nextgroup=pieProcessorBody skipwhite
syntax region pieProcessorBody matchgroup=pieProcessorFence start="```$" keepend end="^```" contains=@javascript

syntax match pieHttpTopLevel "^" nextgroup=pieHttpHeaderKey
syntax match pieEnv "^@\h\w\+:" nextgroup=pieEnvValue skipnl
syntax match pieEnvValue "^\s\+" nextgroup=pieHttpHeaderKey,pieVarAssignment skipnl

syntax match pieVarIdentifier "$\h\w\+" nextgroup=pieVarAssignment skipwhite
syntax match pieVarAssignment "=" contained nextgroup=jsonString,pieNumber skipwhite
syntax match pieNumber "[1-9]\d*" contained

syntax region pieJsonObjectBody start="{\@=" end="}\@<=" contains=@json

syntax match pieComment "\v#.*$"

hi default link pieComment Comment
hi default link pieEnv Structure

hi default link pieVarIdentifier Identifier
hi default link pieNumber Number

hi default link pieHttpVerb Define
hi default link pieHttpPath Character
hi default link pieHttpHeaderKey Label
hi default link pieHttpHeaderValue Constant

hi default link pieProcessorVerb Structure
hi default link pieProcessorFence Delimiter
hi default link pieProcessorIdentifier Identifier
hi default link pieProcessorId Identifier
