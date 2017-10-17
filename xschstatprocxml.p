
/* xdrm/xsch/xschstatprocxml.p - Process message to update booking status

28/08/2017 mob  - ws12166 - New File
--------------------------------------------------------------------------- */

define input  parameter ipiSmSerial    as integer   no-undo.
define output parameter oplSuccess     as logical   no-undo.

define variable lSuccess as logical no-undo.

{xpro/xsys/xsyserrors.v}
{xdrm/xblg/xblgbookstatupd.v}

define variable cLongChar as longchar no-undo.

define dataset CRConfirmation
  for ttBookStatUpdCriteria.

find first sysmsgxx
  where sysmsgxx.sm-serial    = ipiSmSerial
  and   sysmsgxx.sm-processed = ?
  no-lock no-error.
if not available sysmsgxx then
  return.
  
/* Store the XML into the temp tables */
assign cLongChar = sysmsgxx.sm-xml.

empty temp-table ttBookStatUpdParams.
empty temp-table ttBookStatUpdCriteria.

create ttBookStatUpdParams.
assign ttBookStatUpdParams.User_ID       = sysmsgxx.sm-creator
       ttBookStatUpdParams.SuppressEmail = false.

dataset CRConfirmation:read-xml ("longchar",
                                 cLongChar,
                                 "empty",
                                 "",
                                 false).

run xdrm/xblg/xblgbookstatupd.p (input table ttBookStatUpdParams,
                                 input table ttBookStatUpdCriteria,
                                 input-output table ttErrors,
                                 output lSuccess).
                                 
if lSuccess = false then
  return.
  
assign oplSuccess = true.