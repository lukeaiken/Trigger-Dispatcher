Trigger Dispatcher framework whereby each handler implements a shared interface and is dispatched to based on SObjectType and TriggerOperation. An activeFunction may be set to drive trigger handling that is a result of DML within a trigger context granting full control over recursion and order of executed logic. AppConfig Custom Setting provides an on/off switch. TriggerDMLSupport may be leveraged to safely consolidate all SObject updates within a trigger context.
