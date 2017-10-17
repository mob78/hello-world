
/* xpro/xsys/xsysmsgcreate.p - Create system messages

22/08/2017 mob  - ws12166 - Program created
--------------------------------------------------------------------------- */

{xpro/xsys/xsysmsgcreate.v}
{xpro/xsys/xsyserrors.v}

define input  parameter table for ttMsgCreateParams.
define input  parameter table for ttMsgCreateCriteria.
define input  parameter dataset-handle iphDataSet.
define input-output parameter table for ttErrors.
define output parameter oplSuccess as logical no-undo.

define variable lcXML as longchar no-undo.

find ttMsgCreateParams no-error.
if not available ttMsgCreateParams then
do:
  run pCreateError (input "Error",
                    input "Missing ttMsgCreateParams record.").
  return.
end.


createBlk:
for first ttMsgCreateCriteria
  transaction:    

  iphDataSet:write-xml("longchar",
                       lcXML,
                       true,        /* formatted */
                       "UTF-8",     /* encoding */
                       ?,           /* schema loc */
                       false,       /* write-schema */
                       false,       /* min xml schema */
                       false).

  create sysmsgxx.
  assign sysmsgxx.sm-serial    = next-value(s-smserial)
         sysmsgxx.sm-cat       = ttMsgCreateCriteria.sm-cat
         sysmsgxx.sm-type      = ttMsgCreateCriteria.sm-type
         sysmsgxx.sm-int-key   = ttMsgCreateCriteria.sm-int-key
         sysmsgxx.sm-creator   = ttMsgCreateParams.User_ID
         sysmsgxx.sm-created   = now
         sysmsgxx.sm-xml       = lcXML.
  release sysmsgxx.
  
  assign iphDataSet = ?.
  
end.

assign oplSuccess = true.
