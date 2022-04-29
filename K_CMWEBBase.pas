unit K_CMWEBBase;

interface

type TK_WCMSProvAttrs = record
  WCProvID       : Integer; // Provider ID
  WCProvTitle    : string; 	// Provider Title
  WCProvSurname  : string;	// Provider Surname
  WCProvFirstName: string;	// Provider First Name
  WCProvMiddle   : string; 	// Provider Middle Name
end;
type TK_PWCMSProvAttrs = ^TK_WCMSProvAttrs;

type TK_WCMSObjSelCode = (
  wcmsActual,	   // Actual objects
  wcmsMarkAsDel, // Marked As Deleted  objects
  wcmsAll	       // All objects
);

Type  TK_WCMSPatGender = (
  wcmgMale,		// Male Patient
  wcmgFemale	// Female Patient
);
type TK_WCMSPatAttrs = record
  WCPatID       : Integer; 	 // Patient ID
  WCPatCardNum  : string; 	 // Patient Card Number
  WCPatTitle    : string; 	 // Patient Title
  WCPatSurname  : string; 	 // Patient Surname
  WCPatFirstName: string;    // Patient First Name
  WCPatMiddle   : string; 	 // Patient Middle Name
  WCPatDOB      : TDateTime; // Patient Date Of Birth
  WCPatGender   : TK_WCMSPatGender; // Patient Gender
end;

type TK_WCMSPatAttrsArr = array of TK_WCMSPatAttrs;

type TK_WCMSMTypeAttrs = record
  WCMTypeID   : Integer; 	// MediaType ID
  WCMTypeName : string; 	// MediaType Name
end;

type TK_WCMSMTypeAttrsArr = array of TK_WCMSMTypeAttrs;

const
  K_WCMSMTypeAny = -2;
  K_WCMSMTypeUnassined = 0;


type TK_WCMSMediaObjType = (
  wcmtImage, // Image
  wcmtVideo, // Video
  wcmtStudy	 // Study
);

type TK_WCMSMediaObjAttrs =  record
  WCMObjID   : Integer;		    // Media Object ID
  WCMObjType : TK_WCMSMediaObjType;	// Media Object Type
  WCMObjMediaTypeID : Integer;// Media Object Media Type ID
  WCMObjDiagnoses : string;	  // Media Object Diagnoses
  WCMObjTeethInfo : string;	  // Media Object Teeth Chart Info string
  WCMObjTeethFlags: Int64;	  // Media Object Teeth Chart Flags
  WCMObjDTaken    : TDateTime;// Media Object Taken Time Stamp
  WCMObjWidth     : Integer;  // Image or Study width
  WCMObjHeight    : Integer;  // Image or Study height
  WCMObjDuration  : Single; 	// Video Duration in seconds
  WCMObjVideoFExt : string;   // Video File extension
  WCMObjStudyID   : Integer;  // Study ID or 0 if Media Object is not linked to Study
end;
type TK_WCMSMediaObjAttrsArr = array of TK_WCMSMediaObjAttrs;

type TK_WCMSMediaObjFileFormat = (
  wcmfJPG,	// JPEG
  wcmfPNG,	// PNG
  wcmfTIFF,	// TIF
  wcmfBMP	  // BMP
);

type TK_WCMSMediaObjViewCont = (
  wcmcAll,      // Last Image state with User Annotations
  wcmcSkipAnnot,// Last Image state without User Annotations
  wcmcOriginal	// Original Image state (without any changes)
);

type TK_WCMSMediaObjViewConv = (
  wcmvNoEffect,	// without visual effects
  wcmvEmboss,	  // use emboss effect
  wcmvColorize	// use colorize effect
);

type TK_WCMSStudyObjRef =  record
  WCMSRefLeft   : Integer; // Rectangle Area Left position
  WCMSRefTop    : Integer; // Rectangle Area Top position
  WCMSRefRight  : Integer; // Rectangle Area Right position
  WCMSRefBottom : Integer; // Rectangle Area Bottom position
  WCMSRefMObjID : Integer; // Media Object ID
end;
type TK_WCMSStudyObjRefArr = array of TK_WCMSStudyObjRef;

const
  WCMS_Init_Error        : LongWord = $A0000100; // CMS initialization Error
  WCMS_User_Absent       : LongWord = $A0000101; // User was not set by WCMSSetCurrentUser
  WCMS_FilesPath_Invalid : LongWord = $A0000102; // Given File Path is absent
  WCMS_Patient_Absent    : LongWord = $A0000103; // Patient was not set by WCMSSetCurrentPatient
  WCMS_Wrong_Object_Type : LongWord = $A0000104; // Wrong  Media Object Type

implementation

end.
