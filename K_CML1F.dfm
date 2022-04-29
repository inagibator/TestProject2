object K_CML1Form: TK_CML1Form
  Left = 43
  Top = 131
  Caption = 'K_CML1Form'
  ClientHeight = 905
  ClientWidth = 1284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1272
    Height = 900
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '_1'
      object LLLPropDiagn1: TLabel
        Left = 7
        Top = 182
        Width = 330
        Height = 13
        Caption = 
          'Image will be updated because it have been changed by another us' +
          'er'
      end
      object LLLPropDiagn2: TLabel
        Left = 7
        Top = 198
        Width = 437
        Height = 13
        Caption = 
          '%d opened Media object(s) were updated because they have been ch' +
          'anged by other user(s)'
      end
      object LLLUDViewFilters1: TLabel
        Left = 9
        Top = 86
        Width = 272
        Height = 13
        Caption = 'This profile name already exists. Please enter a new name'
      end
      object LLLUDViewFilters2: TLabel
        Left = 9
        Top = 102
        Width = 259
        Height = 13
        Caption = 'Do you confirm that you really want to delete the "%s"?'
      end
      object LLLPropDiagn3: TLabel
        Left = 7
        Top = 214
        Width = 88
        Height = 13
        Caption = 'Slide not choosen!'
      end
      object LLLUDViewFilters3: TLabel
        Left = 9
        Top = 118
        Width = 11
        Height = 13
        Caption = 'All'
      end
      object LLLUDViewFilters4: TLabel
        Left = 9
        Top = 134
        Width = 60
        Height = 13
        Caption = 'User defined'
      end
      object LLLUDViewFilters5: TLabel
        Left = 9
        Top = 150
        Width = 43
        Height = 13
        Caption = 'BiteWing'
      end
      object LLLPropDiagn4: TLabel
        Left = 7
        Top = 230
        Width = 74
        Height = 13
        Caption = 'LLLPropDiagn4'
      end
      object LLLSelLoc1: TLabel
        Left = 511
        Top = 19
        Width = 244
        Height = 13
        Caption = 'Selected practice is now being edited by other user.'
      end
      object LLLSelLoc2: TLabel
        Left = 511
        Top = 35
        Width = 468
        Height = 13
        Caption = 
          'This practice couldn'#39't be deleted. It is linked to corresponding' +
          ' Practice Management System object.'
      end
      object LLLSelLoc3: TLabel
        Left = 511
        Top = 51
        Width = 222
        Height = 13
        Caption = 'This practice is now being edited by other user.'
      end
      object LLLSelLoc4: TLabel
        Left = 511
        Top = 67
        Width = 259
        Height = 13
        Caption = 'Please confirm you wish to delete "%s" Dental Practice'
      end
      object LLLSelLoc5: TLabel
        Left = 511
        Top = 83
        Width = 250
        Height = 13
        Caption = 'This practice has been already deleted by other user.'
      end
      object LLLSelLoc6: TLabel
        Left = 511
        Top = 99
        Width = 208
        Height = 13
        Caption = 'This practice is controled by other user now.'
      end
      object LLLSelLoc7: TLabel
        Left = 511
        Top = 115
        Width = 319
        Height = 13
        Caption = 
          'Please confirm you wish to permanently delete "%s" Dental Practi' +
          'ce'
      end
      object LLLSelLoc8: TLabel
        Left = 511
        Top = 131
        Width = 253
        Height = 13
        Caption = 'This practice has been already restored by other user.'
      end
      object LLLSelLoc9: TLabel
        Left = 511
        Top = 147
        Width = 277
        Height = 13
        Caption = 'Dental Practice is not selected. Select Practice before exit.'
      end
      object LLLSelLoc10: TLabel
        Left = 511
        Top = 163
        Width = 276
        Height = 13
        Caption = 'Current Practice was deleted. Select new current Practice.'
      end
      object LLLSelLoc11: TLabel
        Left = 511
        Top = 179
        Width = 73
        Height = 13
        Caption = 'Modify Practice'
      end
      object LLLSelLoc12: TLabel
        Left = 511
        Top = 195
        Width = 72
        Height = 13
        Caption = 'Practice details'
      end
      object LLLSelLoc13: TLabel
        Left = 511
        Top = 211
        Width = 64
        Height = 13
        Caption = 'New Practice'
      end
      object LLLSelPat1: TLabel
        Left = 7
        Top = 264
        Width = 231
        Height = 13
        Caption = 'Patient is not selected. Select Patient before exit.'
      end
      object LLLSelPat2: TLabel
        Left = 7
        Top = 280
        Width = 264
        Height = 13
        Caption = 'Current Patient was deleted. Select new current Patient.'
      end
      object LLLSelPat3: TLabel
        Left = 7
        Top = 296
        Width = 548
        Height = 13
        Caption = 
          'Patient Card Number is not unique. Type a unique number or clear' +
          ' the Card Number field for auto card number insert.'
      end
      object LLLSelPat4: TLabel
        Left = 7
        Top = 312
        Width = 238
        Height = 13
        Caption = 'Selected patient is now being edited by other user.'
      end
      object LLLSelPat5: TLabel
        Left = 7
        Top = 328
        Width = 462
        Height = 13
        Caption = 
          'This patient couldn'#39't be deleted. It is linked to corresponding ' +
          'Practice Management System object.'
      end
      object LLLSelPat6: TLabel
        Left = 7
        Top = 344
        Width = 216
        Height = 13
        Caption = 'This patient is now being edited by other user.'
      end
      object LLLSelPat7: TLabel
        Left = 7
        Top = 360
        Width = 240
        Height = 13
        Caption = 'Please confirm you wish to delete patient %s %s %s'
      end
      object LLLSelPat8: TLabel
        Left = 7
        Top = 376
        Width = 244
        Height = 13
        Caption = 'This patient has been already deleted by other user.'
      end
      object LLLSelPat9: TLabel
        Left = 7
        Top = 392
        Width = 202
        Height = 13
        Caption = 'This patient is controled by other user now.'
      end
      object LLLSelPat10: TLabel
        Left = 7
        Top = 408
        Width = 300
        Height = 13
        Caption = 'Please confirm you wish to permanently delete patient %s %s %s'
      end
      object LLLSelPat11: TLabel
        Left = 7
        Top = 424
        Width = 247
        Height = 13
        Caption = 'This patient has been already restored by other user.'
      end
      object LLLSelPat12: TLabel
        Left = 7
        Top = 440
        Width = 58
        Height = 13
        Caption = 'New Patient'
      end
      object LLLSelPat13: TLabel
        Left = 7
        Top = 456
        Width = 67
        Height = 13
        Caption = 'Modify Patient'
      end
      object LLLSelPat14: TLabel
        Left = 7
        Top = 472
        Width = 66
        Height = 13
        Caption = 'Patient details'
      end
      object LLLObjEdit1: TLabel
        Left = 3
        Top = 504
        Width = 144
        Height = 13
        Caption = 'Display interim measurements?'
      end
      object LLLObjEdit2: TLabel
        Left = 3
        Top = 520
        Width = 180
        Height = 13
        Caption = 'Length should be between %g and %s'
      end
      object LLLObjEdit3: TLabel
        Left = 3
        Top = 536
        Width = 67
        Height = 13
        Caption = 'Text attributes'
      end
      object LLLObjEdit4: TLabel
        Left = 3
        Top = 552
        Width = 128
        Height = 13
        Caption = 'Click at polyline start vertex'
      end
      object LLLObjEdit5: TLabel
        Left = 3
        Top = 568
        Width = 119
        Height = 13
        Caption = 'Click at arrow start vertex'
      end
      object LLLObjEdit6: TLabel
        Left = 3
        Top = 584
        Width = 144
        Height = 13
        Caption = 'Click at rectangle start position'
      end
      object LLLObjEdit7: TLabel
        Left = 3
        Top = 600
        Width = 129
        Height = 13
        Caption = 'Click at ellipse start position'
      end
      object LLLObjEdit8: TLabel
        Left = 3
        Top = 616
        Width = 123
        Height = 13
        Caption = 'Click at Angle Start Vertex'
      end
      object LLLObjEdit9: TLabel
        Left = 3
        Top = 632
        Width = 98
        Height = 13
        Caption = 'Click at Text position'
      end
      object LLLObjEdit10: TLabel
        Left = 3
        Top = 648
        Width = 130
        Height = 13
        Caption = 'Click at Ellipse start position'
      end
      object LLLObjEdit11: TLabel
        Left = 200
        Top = 504
        Width = 127
        Height = 13
        Caption = 'Click at Arrow start position'
      end
      object LLLObjEdit12: TLabel
        Left = 200
        Top = 520
        Width = 182
        Height = 13
        Caption = 'Click at Calibrate Segment Start Vertex'
      end
      object LLLObjEdit13: TLabel
        Left = 200
        Top = 536
        Width = 264
        Height = 13
        Caption = 'Click at Flashlight resulting position or Escape to remove'
      end
      object LLLObjEdit14: TLabel
        Left = 200
        Top = 552
        Width = 265
        Height = 13
        Caption = 'Mouse Double Click or Escape to finish Polyline creation'
      end
      object LLLObjEdit15: TLabel
        Left = 200
        Top = 568
        Width = 188
        Height = 13
        Caption = 'Mouse Up/Click to finish Elipse creation'
      end
      object LLLObjEdit16: TLabel
        Left = 200
        Top = 584
        Width = 209
        Height = 13
        Caption = 'Mouse Up/Click to finish Rectangle creation'
      end
      object LLLObjEdit17: TLabel
        Left = 200
        Top = 600
        Width = 210
        Height = 13
        Caption = 'Mouse Up/Click to finish Arrow Line creation'
      end
      object LLLObjEdit18: TLabel
        Left = 200
        Top = 616
        Width = 284
        Height = 13
        Caption = 'Mouse Up/Click or Escape to finish Free Hand Line creation'
      end
      object LLLObjEdit19: TLabel
        Left = 200
        Top = 632
        Width = 257
        Height = 13
        Caption = 'Mouse Double Click or Escape/Del to finish calibration'
      end
      object LLLObjEdit20: TLabel
        Left = 200
        Top = 648
        Width = 175
        Height = 13
        Caption = 'Press Escape to finish Angle creation'
      end
      object LLLObjEdit21: TLabel
        Left = 398
        Top = 504
        Width = 385
        Height = 13
        Caption = 
          'Put Free Angle Last Segment Start Vertex or press Escape to fini' +
          'sh Angle creation'
      end
      object LLLObjEdit22: TLabel
        Left = 494
        Top = 520
        Width = 49
        Height = 13
        Caption = 'Add Angle'
      end
      object LLLObjEdit23: TLabel
        Left = 494
        Top = 536
        Width = 19
        Height = 13
        Caption = 'Add'
      end
      object LLLObjEdit24: TLabel
        Left = 495
        Top = 552
        Width = 81
        Height = 13
        Caption = 'Move Annotation'
      end
      object LLLObjEdit25: TLabel
        Left = 495
        Top = 568
        Width = 114
        Height = 13
        Caption = 'Move Annotation Vertex'
      end
      object LLLObjEdit26: TLabel
        Left = 495
        Top = 584
        Width = 86
        Height = 13
        Caption = 'Resize Annotation'
      end
      object LLLImgFilterProc1: TLabel
        Left = 278
        Top = 439
        Width = 241
        Height = 13
        Caption = ' Image is processing by custom filter. Please wait ...'
      end
      object LLLImgFilterProc2: TLabel
        Left = 278
        Top = 454
        Width = 164
        Height = 13
        Caption = 'Image is processed by custom filter'
      end
      object LLLImgFilterProc3: TLabel
        Left = 278
        Top = 470
        Width = 22
        Height = 13
        Caption = 'Filter'
      end
      object LLLTools1: TLabel
        Left = 552
        Top = 328
        Width = 88
        Height = 13
        Caption = 'Set Image Emboss'
      end
      object LLLTools2: TLabel
        Left = 552
        Top = 344
        Width = 98
        Height = 13
        Caption = 'Set Image Isodensity'
      end
      object LLLTools3: TLabel
        Left = 552
        Top = 360
        Width = 116
        Height = 13
        Caption = 'Image autoequalized OK'
      end
      object LLLTools4: TLabel
        Left = 552
        Top = 376
        Width = 241
        Height = 13
        Caption = ' Image is processing by custom filter. Please wait ...'
      end
      object LLLTools5: TLabel
        Left = 552
        Top = 392
        Width = 181
        Height = 13
        Caption = 'Image is processed by custom filter %d'
      end
      object LLLTools6: TLabel
        Left = 552
        Top = 408
        Width = 235
        Height = 13
        Caption = ' Image is processing by global filter. Please wait ...'
      end
      object LLLTools7: TLabel
        Left = 552
        Top = 424
        Width = 174
        Height = 13
        Caption = 'Image is processed by global filter %s'
      end
      object LLLTools8: TLabel
        Left = 552
        Top = 440
        Width = 81
        Height = 13
        Caption = 'Image is cropped'
      end
      object LLLTools9: TLabel
        Left = 552
        Top = 456
        Width = 99
        Height = 13
        Caption = 'Brightness / Contrast'
      end
      object LLLMedia1: TLabel
        Left = 598
        Top = 179
        Width = 153
        Height = 13
        Caption = ' %d Media object(s) are imported'
      end
      object LLLMedia2: TLabel
        Left = 598
        Top = 195
        Width = 223
        Height = 13
        Caption = ' %d Media object(s) are imported from Clipboard'
      end
      object LLLMedia3: TLabel
        Left = 598
        Top = 211
        Width = 130
        Height = 13
        Caption = 'One Media Object exported'
      end
      object LLLMedia4: TLabel
        Left = 598
        Top = 227
        Width = 154
        Height = 13
        Caption = ' %d Media object(s) are exported'
      end
      object LLLMedia5: TLabel
        Left = 598
        Top = 243
        Width = 162
        Height = 13
        Caption = ' %d Media object(s) are duplicated'
      end
      object LLLMedia6: TLabel
        Left = 598
        Top = 259
        Width = 155
        Height = 13
        Caption = ', %d Media Files are inaccessible'
      end
      object LLLMedia7: TLabel
        Left = 598
        Top = 275
        Width = 149
        Height = 13
        Caption = ' %d Media object(s) are emailed'
      end
      object LLLEdit1: TLabel
        Left = 872
        Top = 80
        Width = 153
        Height = 13
        Caption = ' %d Media object(s) are selected'
      end
      object LLLEdit2: TLabel
        Left = 872
        Top = 96
        Width = 94
        Height = 13
        Caption = 'Last Action Undone'
      end
      object LLLEdit3: TLabel
        Left = 872
        Top = 112
        Width = 94
        Height = 13
        Caption = 'Last Action Redone'
      end
      object LLLEdit4: TLabel
        Left = 872
        Top = 128
        Width = 93
        Height = 13
        Caption = '%d Actions Redone'
      end
      object LLLEdit5: TLabel
        Left = 872
        Top = 144
        Width = 93
        Height = 13
        Caption = '%d Actions Undone'
      end
      object LLLEdit6: TLabel
        Left = 872
        Top = 160
        Width = 118
        Height = 13
        Caption = 'Original Image is restored'
      end
      object LLLEdit7: TLabel
        Left = 872
        Top = 176
        Width = 135
        Height = 13
        Caption = ' %d object(s) are dismounted'
      end
      object LLLImportChng1: TLabel
        Left = 632
        Top = 528
        Width = 178
        Height = 13
        Caption = 'Do you really want to stop the action?'
      end
      object LLLImportChng2: TLabel
        Left = 632
        Top = 544
        Width = 380
        Height = 13
        Caption = 
          'The action is stopped. %d objects of %d are processed, %d images' +
          ' are changed.'
      end
      object LLLImportChng3: TLabel
        Left = 632
        Top = 560
        Width = 222
        Height = 13
        Caption = 'New attributes are not specified. Nothing to do.'
      end
      object LLLImportChng4: TLabel
        Left = 632
        Top = 576
        Width = 363
        Height = 13
        Caption = 
          'The action is finished. All %d objects are processed, %d images ' +
          'are changed.'
      end
      object LLLRebuildSlidesView1: TLabel
        Left = 8
        Top = 712
        Width = 170
        Height = 13
        Caption = ' %d of %d media object(s) are visible'
      end
      object LLLDBImportRev1: TLabel
        Left = 816
        Top = 240
        Width = 327
        Height = 13
        Caption = 
          'Do you confirm that you really want\#to remove %d imported objec' +
          'ts?'
      end
      object LLLDBImportRev2: TLabel
        Left = 816
        Top = 256
        Width = 136
        Height = 13
        Caption = 'Objects deletion confirmation'
      end
      object LLLDBImportRev3: TLabel
        Left = 816
        Top = 272
        Width = 58
        Height = 13
        Caption = '%5d deleted'
      end
      object LLLDBImportRev4: TLabel
        Left = 816
        Top = 288
        Width = 247
        Height = 13
        Caption = ' %d Media object(s) have been used by other user(s)'
      end
      object LLLDBImportRev5: TLabel
        Left = 816
        Top = 304
        Width = 251
        Height = 13
        Caption = ' %d Media object(s) were created on other computers'
      end
      object LLLDBImportRev6: TLabel
        Left = 816
        Top = 320
        Width = 250
        Height = 13
        Caption = ' %d Media object(s) of %d have been already deleted'
      end
      object LLLDBImportRev7: TLabel
        Left = 816
        Top = 336
        Width = 268
        Height = 13
        Caption = ' %d Media object(s) of %d were deleted by import reverse'
      end
      object LLLDBImportRev8: TLabel
        Left = 816
        Top = 352
        Width = 98
        Height = 13
        Caption = ' %d object(s) deleted'
      end
      object LLLSupport1: TLabel
        Left = 816
        Top = 384
        Width = 107
        Height = 13
        Caption = ' The Software Support'
      end
      object LLLSupport2: TLabel
        Left = 816
        Top = 400
        Width = 225
        Height = 13
        Caption = ' The Software Support terminated by exception:'
      end
      object LLLProfile1: TLabel
        Left = 816
        Top = 424
        Width = 192
        Height = 13
        Caption = 'Selected device profile "%s" is corrupted'
      end
      object LLLProfile2: TLabel
        Left = 816
        Top = 440
        Width = 260
        Height = 13
        Caption = #1057'apture device is not selected. Profile will not be saved'
      end
      object LLLUndoRedo1: TLabel
        Left = 376
        Top = 16
        Width = 50
        Height = 13
        Caption = 'Initial state'
      end
      object LLLHist1: TLabel
        Left = 376
        Top = 32
        Width = 47
        Height = 13
        Caption = 'Histogram'
      end
      object LLLPrefEdit1: TLabel
        Left = 574
        Top = 638
        Width = 271
        Height = 13
        Caption = 'Are you sure you want to delete this '#39'%s'#39' Media Category?'
      end
      object LLLPrefEdit2: TLabel
        Left = 574
        Top = 654
        Width = 348
        Height = 13
        Caption = 
          'The Media Category '#39'%s'#39' already exists.\#       Please enter ano' +
          'ther name.'
      end
      object LLLPrefEdit3: TLabel
        Left = 574
        Top = 670
        Width = 430
        Height = 13
        Caption = 
          'You can'#39't delete this '#39'%s'#39' Media Category because it is\#used in' +
          ' patient'#39's %s Media Objects'
      end
      object LLLPrefEdit4: TLabel
        Left = 574
        Top = 686
        Width = 28
        Height = 13
        Caption = 'Setup'
      end
      object LLLGASettings1: TLabel
        Left = 7
        Top = 736
        Width = 250
        Height = 13
        Caption = ' User name length should not be less than 4 symbols.'
      end
      object LLLGASettings2: TLabel
        Left = 7
        Top = 752
        Width = 245
        Height = 13
        Caption = ' Password length should not be less than 4 symbols.'
      end
      object LLLGASettings3: TLabel
        Left = 7
        Top = 768
        Width = 190
        Height = 13
        Caption = ' Entered password differs from repeated.'
      end
      object LLLGASettings4: TLabel
        Left = 7
        Top = 784
        Width = 319
        Height = 13
        Caption = 
          ' User name and password length should not be less than 4 symbols' +
          '.'
      end
      object LLLExport1: TLabel
        Left = 376
        Top = 736
        Width = 167
        Height = 13
        Caption = 'File or folder "%s" exists, overwrite?'
      end
      object LLLExport2: TLabel
        Left = 376
        Top = 752
        Width = 780
        Height = 13
        Caption = 
          'There is not enough space in the destination folder.\#Only %d ob' +
          'ject(s) out of %d have been exported.\#Please select another exp' +
          'ort folder and repeat the operation.'
      end
      object LLLShortcutNone: TLabel
        Left = 376
        Top = 64
        Width = 26
        Height = 13
        Caption = 'None'
      end
      object LLLSave1: TLabel
        Left = 616
        Top = 712
        Width = 239
        Height = 13
        Caption = ' %d media object(s) of %d are saved ... Please wait'
      end
      object LLLSave2: TLabel
        Left = 616
        Top = 728
        Width = 141
        Height = 13
        Caption = ' Image is busy. Wait please ...'
      end
      object LLLDelProfile1: TLabel
        Left = 872
        Top = 608
        Width = 225
        Height = 13
        Caption = 'Are you sure you want to delete this '#39'%s'#39' profile?'
      end
      object LLLDelProfile2: TLabel
        Left = 872
        Top = 624
        Width = 250
        Height = 13
        Caption = 'Bad device Profile. Please delete it and create again.'
      end
      object LLLWrongNameOrPassword: TLabel
        Left = 344
        Top = 376
        Width = 147
        Height = 13
        Caption = ' Wrong user name or password'
      end
      object LLLWrongPassword: TLabel
        Left = 344
        Top = 360
        Width = 83
        Height = 13
        Caption = ' Wrong password'
      end
      object LLLFinishActionAndRestart: TLabel
        Left = 280
        Top = 160
        Width = 206
        Height = 13
        Caption = 'Finish this action and restart the application.'
      end
      object LLLDelOpened1: TLabel
        Left = 176
        Top = 224
        Width = 285
        Height = 13
        Caption = 'Do you confirm that you really want to delete opened image?'
      end
      object LLLNewMediaType: TLabel
        Left = 840
        Top = 208
        Width = 99
        Height = 13
        Caption = 'New Media Category'
      end
      object LLLSetLogFilesPath1: TLabel
        Left = 912
        Top = 704
        Width = 128
        Height = 13
        Caption = ' UserIni file is not specified '
      end
      object LLLSetLogFilesPath2: TLabel
        Left = 912
        Top = 720
        Width = 135
        Height = 13
        Caption = ' UserIni (%s) file is not found '
      end
      object LLLRestoreDelSlides1: TLabel
        Left = 816
        Top = 472
        Width = 355
        Height = 13
        Caption = 
          ' %d Media object(s) have been already deleted by other Media Sui' +
          'te user(s)'
      end
      object LLLRestoreDelSlides2: TLabel
        Left = 816
        Top = 488
        Width = 140
        Height = 13
        Caption = ' %d object(s) were restored%s'
      end
      object LLLFilesMove: TLabel
        Left = 328
        Top = 88
        Width = 124
        Height = 13
        Caption = 'Current folder doesn'#39't exist'
      end
      object LLLDeviceSetup: TLabel
        Left = 566
        Top = 832
        Width = 373
        Height = 13
        Caption = 
          ' This area is for advanced users only.\#If you wish to proceed, ' +
          'enter password.'
      end
      object LLLActionFin: TLabel
        Left = 976
        Top = 16
        Width = 200
        Height = 13
        Caption = 'Application wait error have been detected.'
      end
      object LLLDelOpened2: TLabel
        Left = 176
        Top = 240
        Width = 282
        Height = 13
        Caption = 'Do you confirm that you really want to delete opened study?'
      end
      object LLLMedia8: TLabel
        Left = 598
        Top = 291
        Width = 213
        Height = 13
        Caption = ' %d Media object(s) are exported to Clipboard'
      end
      object LLLImg3D1: TLabel
        Left = 1070
        Top = 43
        Width = 104
        Height = 13
        Caption = ' 3D Object is imported'
      end
      object LLLImg3D2: TLabel
        Left = 1070
        Top = 59
        Width = 88
        Height = 13
        Caption = ' 3D Object and %s'
      end
      object LLLImg3D3: TLabel
        Left = 1070
        Top = 75
        Width = 122
        Height = 13
        Caption = '%d 3D views are imported'
      end
      object LLLImg3D4: TLabel
        Left = 1070
        Top = 91
        Width = 202
        Height = 13
        Caption = 'This object is already opened by other user'
      end
      object LLLObjEdit27: TLabel
        Left = 495
        Top = 600
        Width = 165
        Height = 13
        Caption = 'Click+Shift to modify Text attributes'
      end
      object LLLObjEdit28: TLabel
        Left = 495
        Top = 616
        Width = 94
        Height = 13
        Caption = 'Click at Dot position'
      end
      object LLLExport3: TLabel
        Left = 376
        Top = 768
        Width = 507
        Height = 13
        Caption = 
          'The folder "%s" doesn'#8217't exist.\#Click OK to automatically create' +
          ' this folder or Cancel to change export path.'
      end
      object LLLExport4: TLabel
        Left = 376
        Top = 784
        Width = 745
        Height = 13
        Caption = 
          'Mediasuite cannot create the folder "%s".\#The default folder "%' +
          's" can be used to export the images.\#Click OK to proceed or Can' +
          'cel to change export path.'
      end
      object LLLDistUnitsFormat: TComboBox
        Left = 12
        Top = 6
        Width = 93
        Height = 59
        AutoComplete = False
        Style = csSimple
        TabOrder = 0
        Text = 'DistUnitsFormat'
        Visible = False
        Items.Strings = (
          '%.*f mm'
          '%.*f inch')
      end
      object LLLDistUnitsAliase: TComboBox
        Left = 124
        Top = 6
        Width = 93
        Height = 59
        AutoComplete = False
        Style = csSimple
        TabOrder = 1
        Text = 'DistUnitsAliase'
        Visible = False
        Items.Strings = (
          'millimetres'
          'inches')
      end
      object LLLResolutionUnitsAliase: TComboBox
        Left = 236
        Top = 6
        Width = 93
        Height = 67
        AutoComplete = False
        Style = csSimple
        TabOrder = 2
        Text = 'ResolutionUnitsAliase'
        Visible = False
        Items.Strings = (
          'Pixel size, '#181'm'
          'Pixels per mm'
          'DPI')
      end
    end
    object TabSheet2: TTabSheet
      Caption = '_2'
      ImageIndex = 1
      object LLLSysInfo1: TLabel
        Left = 136
        Top = 64
        Width = 117
        Height = 13
        Caption = '%s (%.2n MB) [%.0n files]'
      end
      object LLLSysInfo2: TLabel
        Left = 136
        Top = 80
        Width = 111
        Height = 13
        Caption = '%.2n MB [%.0n objects]'
      end
      object LLLSysInfo3: TLabel
        Left = 136
        Top = 96
        Width = 256
        Height = 13
        Caption = 'Do you really want to break database fields preparing?'
      end
      object LLLSysInfo4: TLabel
        Left = 136
        Top = 112
        Width = 231
        Height = 13
        Caption = 'Do you really want to break files size calculation?'
      end
      object LLLThumbsRFrame1: TLabel
        Left = 8
        Top = 152
        Width = 126
        Height = 13
        Caption = 'This object is already open'
      end
      object LLLThumbsRFrame2: TLabel
        Left = 8
        Top = 168
        Width = 535
        Height = 13
        Caption = 
          ' Media object is marked as deleted. It couldn'#39't be changed.\# Pl' +
          'ease restore it'#39's state first if you wish to change it.'
      end
      object LLLThumbsRFrame3: TLabel
        Left = 8
        Top = 184
        Width = 402
        Height = 13
        Caption = 
          ' Media object is opened by other user(s).\# Any changes made to ' +
          'it will not be saved.'
      end
      object LLLThumbsRFrame4: TLabel
        Left = 8
        Top = 200
        Width = 719
        Height = 13
        Caption = 
          ' Media object is from another location.\# Any changes made to it' +
          ' will not be saved.\# Please duplicate the object first\# if you' +
          ' wish to save the changes.'
      end
      object LLLDBImport1: TLabel
        Left = 8
        Top = 224
        Width = 177
        Height = 13
        Caption = 'Do you really want to interrupt import?'
      end
      object LLLDBImport2: TLabel
        Left = 8
        Top = 240
        Width = 130
        Height = 13
        Caption = 'Import interrupt confirmation'
      end
      object LLLDBImport3: TLabel
        Left = 8
        Top = 256
        Width = 633
        Height = 13
        Caption = 
          '                The software cannot continue the import.\#Please' +
          ' free up more space on your Server PC Hard Drive and resume the ' +
          'import.'
      end
      object LLLDBImport4: TLabel
        Left = 8
        Top = 272
        Width = 434
        Height = 13
        Caption = 
          'The Software requires minimum 1,000.00Mb of free space to import' +
          ' objects after conversion.'
      end
      object LLLDBImport5: TLabel
        Left = 8
        Top = 288
        Width = 394
        Height = 13
        Caption = 
          'Please free up more space on your Server PC Hard Drive and start' +
          ' the import again.'
      end
      object LLLDBImport6: TLabel
        Left = 8
        Top = 304
        Width = 342
        Height = 13
        Caption = 
          '     You can only undo your last conversion. Do you still wish t' +
          'o proceed?'
      end
      object LLLDBImport7: TLabel
        Left = 8
        Top = 320
        Width = 177
        Height = 13
        Caption = 'Are you sure you want to stop import?'
      end
      object LLLDBImport8: TLabel
        Left = 8
        Top = 336
        Width = 609
        Height = 13
        Caption = 
          '     File "Patient.txt" is not found. The import is not possible' +
          '.\#Please locate the file "Patient.txt" and copy it to the conve' +
          'rter folder'
      end
      object LLLDBImport9: TLabel
        Left = 8
        Top = 352
        Width = 260
        Height = 13
        Caption = 'Total objects number in file %d differs from previous %d.'
      end
      object LLLDBImport10: TLabel
        Left = 8
        Top = 368
        Width = 144
        Height = 13
        Caption = 'Try to continue import from %s.'
      end
      object LLLDBImport11: TLabel
        Left = 8
        Top = 384
        Width = 424
        Height = 13
        Caption = 
          'If you select "Yes" new import will be started.\#Are you sure yo' +
          'u want to start new import?'
      end
      object LLLDBImport12: TLabel
        Left = 8
        Top = 400
        Width = 235
        Height = 13
        Caption = '%d of %d processed slides were imported from %s.'
      end
      object LLLDBImport13: TLabel
        Left = 8
        Top = 416
        Width = 102
        Height = 13
        Caption = '%d errors were found.'
      end
      object LLLDBImport14: TLabel
        Left = 8
        Top = 432
        Width = 164
        Height = 13
        Caption = 'File %s doesn'#39't contain proper data'
      end
      object LLLDBImport15: TLabel
        Left = 8
        Top = 448
        Width = 235
        Height = 13
        Caption = ' %d slide(s) were imported, %d error(s) were found.'
      end
      object LLLSlidesOpen1: TLabel
        Left = 8
        Top = 480
        Width = 440
        Height = 13
        Caption = 
          ' %d opened Media object(s) were updated because they have been c' +
          'hanged by other user(s)'
      end
      object LLLSlidesOpen2: TLabel
        Left = 8
        Top = 496
        Width = 276
        Height = 13
        Caption = ' Media object(s) opened in this mode couldn'#39't be changed.'
      end
      object LLLSlidesOpen3: TLabel
        Left = 8
        Top = 512
        Width = 621
        Height = 13
        Caption = 
          ' %d Media object(s) are marked as deleted. They couldn'#39't be chan' +
          'ged.\#   Please restore their state first if you wish to change ' +
          'them.'
      end
      object LLLSlidesOpen4: TLabel
        Left = 8
        Top = 528
        Width = 456
        Height = 13
        Caption = 
          ' %d Media object(s) are opened by other user(s).\# Any changes m' +
          'ade to them will not be saved.'
      end
      object LLLSlidesOpen5: TLabel
        Left = 8
        Top = 544
        Width = 1147
        Height = 13
        Caption = 
          ' %d Media object(s) are opened by other user(s).\# %d Media obje' +
          'ct(s) are from another location(s).\# Any changes made to them w' +
          'ill not be saved.\# Please duplicate the object(s) from another\' +
          '# location(s) first if you wish to save the changes.'
      end
      object LLLSlidesOpen6: TLabel
        Left = 8
        Top = 560
        Width = 795
        Height = 13
        Caption = 
          ' %d Media object(s) are from another location(s).\# Any changes ' +
          'made to them will not be saved.\# Please duplicate the object(s)' +
          ' first\# if you wish to save the changes.'
      end
      object LLLSlidesOpen7: TLabel
        Left = 8
        Top = 576
        Width = 429
        Height = 13
        Caption = 
          'There are too many objects to display in the "Studio" area. %d o' +
          'bjects will not be displayed.'
      end
      object LLLSlidesOpen8: TLabel
        Left = 8
        Top = 592
        Width = 178
        Height = 13
        Caption = ' %d images are loaded. Please wait ...'
      end
      object LLLIntegrityCheck8: TLabel
        Left = 8
        Top = 620
        Width = 140
        Height = 13
        Caption = ' %d study file(s) were updated'
      end
      object LLLIntegrityCheck1: TLabel
        Left = 8
        Top = 636
        Width = 377
        Height = 13
        Caption = 
          'Integrity check is now selected by another user\#              P' +
          'lease try again later.'
      end
      object LLLIntegrityCheck2: TLabel
        Left = 8
        Top = 652
        Width = 250
        Height = 13
        Caption = 'Do you really want to break maintenance procedure?'
      end
      object LLLIntegrityCheck3: TLabel
        Left = 8
        Top = 668
        Width = 439
        Height = 13
        Caption = 
          ' Integrity check is %s. %d of %d media object(s) were processed,' +
          ' %d file errors were detected.'
      end
      object LLLIntegrityCheck4: TLabel
        Left = 8
        Top = 684
        Width = 329
        Height = 13
        Caption = 
          ' %d media object(s) were recovered. %d media object(s) were dele' +
          'ted.'
      end
      object LLLIntegrityCheck5: TLabel
        Left = 8
        Top = 700
        Width = 401
        Height = 13
        Caption = 
          ' %d media objects(s) were not recovered because they were opened' +
          ' by other user(s)!'
      end
      object LLLIntegrityCheck6: TLabel
        Left = 8
        Top = 716
        Width = 212
        Height = 13
        Caption = ' %d corrupted image file(s) were moved to %s'
      end
      object LLLIntegrityCheck7: TLabel
        Left = 8
        Top = 732
        Width = 210
        Height = 13
        Caption = ' %d corrupted video file(s) were moved to %s'
      end
      object LLLDBRecovery1: TLabel
        Left = 400
        Top = 8
        Width = 248
        Height = 13
        Caption = 'Do you really want to break DB recovery procedure?'
      end
      object LLLDBRecovery2: TLabel
        Left = 400
        Top = 24
        Width = 584
        Height = 13
        Caption = 
          'Recovering error from file %s\#Media object with ID=%s was alrea' +
          'dy recovered.\#Please check Media object files structure.'
      end
      object LLLDBRecovery3: TLabel
        Left = 400
        Top = 40
        Width = 313
        Height = 13
        Caption = 'Database recovery is %s. %d of %d media objects were recovered.'
      end
      object LLLDBRecovery4: TLabel
        Left = 400
        Top = 56
        Width = 209
        Height = 13
        Caption = '%d corrupted image file(s) were moved to %s'
      end
      object LLLDBRecovery5: TLabel
        Left = 400
        Top = 72
        Width = 207
        Height = 13
        Caption = '%d corrupted video file(s) were moved to %s'
      end
      object LLLSADialogs1: TLabel
        Left = 480
        Top = 624
        Width = 217
        Height = 13
        Caption = 'Please enter the name of your dental practice.'
      end
      object LLLSADialogs2: TLabel
        Left = 480
        Top = 640
        Width = 88
        Height = 13
        Caption = 'My dental Practice'
      end
      object LLLSADialogs3: TLabel
        Left = 480
        Top = 656
        Width = 102
        Height = 13
        Caption = 'Dental Practice name'
      end
      object LLLSADialogs4: TLabel
        Left = 480
        Top = 672
        Width = 89
        Height = 13
        Caption = 'Select the practice'
      end
      object LLLSADialogs5: TLabel
        Left = 480
        Top = 688
        Width = 82
        Height = 13
        Caption = 'Select the dentist'
      end
      object LLLSADialogs6: TLabel
        Left = 480
        Top = 704
        Width = 32
        Height = 13
        Caption = '&Details'
      end
      object LLLSADialogs7: TLabel
        Left = 480
        Top = 720
        Width = 31
        Height = 13
        Caption = '&Modify'
      end
      object LLLReport8: TLabel
        Left = 736
        Top = 720
        Width = 185
        Height = 13
        Caption = 'DB recovery errors report from %s to %s'
      end
      object LLLReport9: TLabel
        Left = 736
        Top = 736
        Width = 294
        Height = 13
        Caption = 'You have unsaved errors report. Press OK to save report data.'
      end
      object LLLReport1: TLabel
        Left = 736
        Top = 608
        Width = 359
        Height = 13
        Caption = 
          'Selected file path\# %s\#Couldn'#39't be created. Please select prop' +
          'er file path.'
      end
      object LLLReport2: TLabel
        Left = 736
        Top = 624
        Width = 401
        Height = 13
        Caption = 
          'Selected full file name\# %s\#Couldn'#39't be created. Please select' +
          ' proper full file name.'
      end
      object LLLReport3: TLabel
        Left = 736
        Top = 640
        Width = 293
        Height = 13
        Caption = 'File %s already exists.\#Please select another report file name.'
      end
      object LLLReport4: TLabel
        Left = 736
        Top = 656
        Width = 166
        Height = 13
        Caption = 'Patient: %-20s Image Object ID: %s'
      end
      object LLLReport5: TLabel
        Left = 736
        Top = 672
        Width = 164
        Height = 13
        Caption = 'Patient: %-20s Video Object ID: %s'
      end
      object LLLReport6: TLabel
        Left = 736
        Top = 688
        Width = 99
        Height = 13
        Caption = 'Report from %s to %s'
      end
      object LLLReport7: TLabel
        Left = 736
        Top = 704
        Width = 188
        Height = 13
        Caption = 'Maintenance errors report from %s to %s'
      end
      object LLLFileAccessCheck10: TLabel
        Left = 768
        Top = 216
        Width = 117
        Height = 13
        Caption = ' Press OK to stop export.'
      end
      object LLLFileAccessCheck11: TLabel
        Left = 768
        Top = 232
        Width = 126
        Height = 13
        Caption = ' Press OK to stop opening.'
      end
      object LLLFileAccessCheck12: TLabel
        Left = 768
        Top = 248
        Width = 131
        Height = 13
        Caption = ' Press OK to stop duplicate.'
      end
      object LLLFileAccessCheck13: TLabel
        Left = 768
        Top = 264
        Width = 126
        Height = 13
        Caption = ' Press OK to stop emailing.'
      end
      object LLLFileAccessCheck14: TLabel
        Left = 768
        Top = 280
        Width = 248
        Height = 13
        Caption = '\#Your objects will be saved in the temporary folder. '
      end
      object LLLChangeSlideAttrs: TLabel
        Left = 8
        Top = 768
        Width = 205
        Height = 13
        Caption = ' %d Object(s) are opened in readonly mode.'
      end
      object LLLSetSessionCont1: TLabel
        Left = 632
        Top = 456
        Width = 301
        Height = 13
        Caption = 'Files are moving to new location! Wait before process complete.'
      end
      object LLLSetSessionCont2: TLabel
        Left = 632
        Top = 472
        Width = 148
        Height = 13
        Caption = 'Image Files Folder is undefined!'
      end
      object LLLSetSessionCont3: TLabel
        Left = 632
        Top = 488
        Width = 212
        Height = 13
        Caption = 'Image and Video Files Folders are undefined!'
      end
      object LLLSetSessionCont4: TLabel
        Left = 632
        Top = 504
        Width = 146
        Height = 13
        Caption = 'Video Files Folder is undefined!'
      end
      object LLLFileAccessCheck1: TLabel
        Left = 768
        Top = 56
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 
          '           There is a problem to access the Images folder.\#Plea' +
          'se check network connection and permission to access this folder' +
          '.\#%sPress OK when ready to continue.%s'
      end
      object LLLFileAccessCheck2: TLabel
        Left = 768
        Top = 72
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 
          '           There is a problem to access the Video folder.\#Pleas' +
          'e check network connection and permission to access this folder.' +
          '\#%sPress OK when ready to continue.%s'
      end
      object LLLFileAccessCheck3: TLabel
        Left = 768
        Top = 88
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 
          '           There is a problem to access the Image and Video fold' +
          'ers.\#Please check network connection and permission to access t' +
          'hese folders.\#%sPress OK when ready to continue.%s'
      end
      object LLLFileAccessCheck4: TLabel
        Left = 768
        Top = 120
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 'The Images folder is still not accessible.%s'
      end
      object LLLFileAccessCheck5: TLabel
        Left = 768
        Top = 136
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 'The Video folder is still not accessible.%s'
      end
      object LLLFileAccessCheck6: TLabel
        Left = 768
        Top = 152
        Width = 402
        Height = 13
        AutoSize = False
        Caption = 'The Images and Video folders are still not accessible.%s'
      end
      object LLLFileAccessCheck7: TLabel
        Left = 768
        Top = 168
        Width = 402
        Height = 13
        AutoSize = False
        Caption = 
          ' Any operation with the Media objects is impossible.\#          ' +
          '                          Do you still wish to proceed?'
      end
      object LLLFileAccessCheck8: TLabel
        Left = 768
        Top = 184
        Width = 402
        Height = 13
        AutoSize = False
        Caption = ' Press Cancel to close the software.'
      end
      object LLLFileAccessCheck9: TLabel
        Left = 768
        Top = 200
        Width = 402
        Height = 13
        AutoSize = False
        Caption = 'Press OK to stop Video data processing.'
      end
      object LLLPrint1: TLabel
        Left = 256
        Top = 768
        Width = 173
        Height = 13
        Caption = 'Paper (width, height): %.0f x %.0f mm'
      end
      object LLLPrint2: TLabel
        Left = 256
        Top = 784
        Width = 83
        Height = 13
        Caption = 'Page %2d of %2d'
      end
      object LLLSelectProfileIcons: TLabel
        Left = 480
        Top = 768
        Width = 91
        Height = 13
        Caption = 'Select Device Icon'
      end
      object LLLCloseCMS: TLabel
        Left = 624
        Top = 768
        Width = 216
        Height = 13
        Caption = 'Close application for technical support please!'
      end
      object LLLExpImpNotSingleUser: TLabel
        Left = 640
        Top = 296
        Width = 206
        Height = 13
        Caption = 'Some users run the software in alone mode.'
      end
      object LLLImpFileIsMissing: TLabel
        Left = 640
        Top = 336
        Width = 354
        Height = 13
        Caption = 
          'File %s is missing. Please copy this file to the XML folder and ' +
          'resume import.'
      end
      object LLLImpFin: TLabel
        Left = 640
        Top = 352
        Width = 195
        Height = 13
        Caption = '    Data  Import from %s\#    is completed.'
      end
      object LLLExpFin: TLabel
        Left = 640
        Top = 312
        Width = 185
        Height = 13
        Caption = '     Data Export to %s\#    is completed.'
      end
      object LLLImpReadFileError: TLabel
        Left = 912
        Top = 368
        Width = 85
        Height = 13
        Caption = 'Read file %s error.'
      end
      object LLLImpReadFileError1: TLabel
        Left = 912
        Top = 384
        Width = 193
        Height = 13
        Caption = 'Read file %s error. Import will be stopped.'
      end
      object LLLExpWrongLinkFName: TLabel
        Left = 624
        Top = 384
        Width = 93
        Height = 13
        Caption = 'Wrong file name %s'
      end
      object LLLSynchFin: TLabel
        Left = 896
        Top = 408
        Width = 200
        Height = 13
        Caption = '     Linking Data from %s\#    is completed.'
      end
      object LLLSetFIO1: TLabel
        Left = 624
        Top = 416
        Width = 107
        Height = 13
        Caption = 'Please enter Surname.'
      end
      object LLLSetFIO2: TLabel
        Left = 624
        Top = 432
        Width = 113
        Height = 13
        Caption = 'Please enter First name.'
      end
      object LLLProceed: TLabel
        Left = 1056
        Top = 208
        Width = 46
        Height = 13
        Caption = 'Proceed?'
      end
      object LLLNothingToDo: TLabel
        Left = 1056
        Top = 224
        Width = 64
        Height = 13
        Caption = 'Nothing to do'
      end
      object LLLPressOkToClose: TLabel
        Left = 1056
        Top = 240
        Width = 148
        Height = 13
        Caption = 'Press OK to close the software.'
      end
      object LLLPressYesToProceed: TLabel
        Left = 1056
        Top = 256
        Width = 101
        Height = 13
        Caption = 'Press Yes to proceed'
      end
      object LLLPressOKToContinue: TLabel
        Left = 1056
        Top = 272
        Width = 100
        Height = 13
        Caption = 'Press OK to continue'
      end
      object LLLDelConfirm: TLabel
        Left = 912
        Top = 296
        Width = 136
        Height = 13
        Caption = 'Objects deletion confirmation'
      end
      object LLLActProceed1: TLabel
        Left = 912
        Top = 312
        Width = 118
        Height = 13
        Caption = 'This action is irreversible.'
      end
      object LLLDelObjs1: TLabel
        Left = 864
        Top = 760
        Width = 324
        Height = 13
        Caption = 
          'Do you confirm that you really want to delete (%d) selected obje' +
          'ct(s)?'
      end
      object LLLDelObjs3: TLabel
        Left = 864
        Top = 776
        Width = 261
        Height = 13
        Caption = '%d not empty study object(s) of %d object(s) are skiped!'
      end
      object LLLDBRecovery6: TLabel
        Left = 400
        Top = 88
        Width = 38
        Height = 13
        Caption = 'stopped'
      end
      object LLLDBRecovery7: TLabel
        Left = 400
        Top = 104
        Width = 36
        Height = 13
        Caption = 'finished'
      end
      object LLLDBRecovery8: TLabel
        Left = 400
        Top = 120
        Width = 127
        Height = 13
        Caption = '%d studies were recovered'
      end
      object LLLDBRecovery9: TLabel
        Left = 400
        Top = 136
        Width = 206
        Height = 13
        Caption = '%d corrupted study file(s) were moved to %s'
      end
      object LLLDBRecovery10: TLabel
        Left = 400
        Top = 152
        Width = 254
        Height = 13
        Caption = '%d duplicated media object(s) were recovered as new'
      end
      object LLLFileAccessCheck31: TLabel
        Left = 768
        Top = 40
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 
          '           There is a problem to access the 3D Images folder.\#P' +
          'lease check network connection and permission to access this fol' +
          'der.\#%sPress OK when ready to continue.%s'
      end
      object LLLFileAccessCheck34: TLabel
        Left = 768
        Top = 104
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 'The 3D Images folder is still not accessible.%s'
      end
      object LLLIntegrityCheck9: TLabel
        Left = 8
        Top = 748
        Width = 245
        Height = 13
        Caption = ' %d corrupted 3D image object(s) were moved to %s'
      end
      object LLLDBRecovery11: TLabel
        Left = 480
        Top = 88
        Width = 242
        Height = 13
        Caption = '%d corrupted 3D image object(s) were moved to %s'
      end
      object LLLDBRecovery12: TLabel
        Left = 480
        Top = 104
        Width = 253
        Height = 13
        Caption = 'there was not enough memory to recover %d object(s)'
      end
      object LLLDBRecovery13: TLabel
        Left = 664
        Top = 8
        Width = 522
        Height = 13
        Caption = 
          'There was not enough memory to recover %d object(s).\#Please clo' +
          'se the software and try DB recovery again!'
      end
      object LLLSysInfo5: TLabel
        Left = 136
        Top = 128
        Width = 133
        Height = 13
        Caption = '%s (%.2n MB) [%.0n objects]'
      end
      object LLLSysInfo6: TLabel
        Left = 136
        Top = 144
        Width = 167
        Height = 13
        Caption = '%d of %d registered licenses in use.'
      end
      object LLLReportHeaderTexts: TComboBox
        Left = 8
        Top = 8
        Width = 109
        Height = 142
        AutoComplete = False
        Style = csSimple
        TabOrder = 0
        Text = 'ReportHeaderTexts'
        Visible = False
        Items.Strings = (
          'Date'
          'Time'
          'Patient'
          'Card Num'
          'User'
          'Action'
          'PC name'
          'Location'
          'Object ID')
      end
      object LLLSysInfoProgress: TComboBox
        Left = 136
        Top = 8
        Width = 93
        Height = 57
        AutoComplete = False
        Style = csSimple
        TabOrder = 1
        Text = 'SysInfo Progress'
        Visible = False
        Items.Strings = (
          'Preparing DB'
          'Calculating')
      end
      object LLLButtonCtrlTexts: TComboBox
        Left = 501
        Top = 375
        Width = 101
        Height = 114
        AutoComplete = False
        Style = csSimple
        TabOrder = 2
        Text = 'ButtonCtrlTexts'
        Visible = False
        Items.Strings = (
          'Start'
          'Resume'
          'Pause'
          'OK'
          'Exit'
          'Cancel')
      end
    end
    object TabSheet3: TTabSheet
      Caption = '_3'
      ImageIndex = 2
      object LLLPathChange1: TLabel
        Left = 16
        Top = 40
        Width = 688
        Height = 13
        Caption = 
          '              Are you sure you want to break the operation?\#(Wo' +
          'rking with Images and Video will be impossible until this operat' +
          'ion is properly finished)'
      end
      object LLLPathChange2: TLabel
        Left = 16
        Top = 56
        Width = 99
        Height = 13
        Caption = 'New folder is not set!'
      end
      object LLLPathChange3: TLabel
        Left = 16
        Top = 72
        Width = 189
        Height = 13
        Caption = 'New folder is the same as current folder!'
      end
      object LLLPathChange4: TLabel
        Left = 16
        Top = 88
        Width = 163
        Height = 13
        Caption = 'New folder has not enough space!'
      end
      object LLLPathChange5: TLabel
        Left = 16
        Top = 104
        Width = 205
        Height = 13
        Caption = 'Are you sure you want to cancel operation?'
      end
      object LLLPathChange6: TLabel
        Left = 16
        Top = 120
        Width = 272
        Height = 13
        Caption = 'Restart the software if you want to use it in ordinary mode.'
      end
      object LLLPathChange7: TLabel
        Left = 16
        Top = 136
        Width = 143
        Height = 13
        Caption = 'Files in new folder are deleted.'
      end
      object LLLPathChange8: TLabel
        Left = 16
        Top = 152
        Width = 849
        Height = 13
        Caption = 
          ' The moving of files to a new folder has already begun. The oper' +
          'ation is to be either\#canceceled or continued after other the s' +
          'oftware instance(s) will be closed on the computer(s):'
      end
      object LLLPathChange9: TLabel
        Left = 16
        Top = 168
        Width = 250
        Height = 13
        Caption = 'Are you realy want to stop moving files to new folder?'
      end
      object LLLPathChange10: TLabel
        Left = 16
        Top = 184
        Width = 85
        Height = 13
        Caption = 'Couldn'#39't copy files'
      end
      object LLLPathChange11: TLabel
        Left = 16
        Top = 200
        Width = 112
        Height = 13
        Caption = 'Files moving is stopped.'
      end
      object LLLPathChange12: TLabel
        Left = 16
        Top = 216
        Width = 141
        Height = 13
        Caption = 'Files are moved to new folder.'
      end
      object LLLPathChange13: TLabel
        Left = 16
        Top = 232
        Width = 277
        Height = 13
        Caption = 'Total number of moved files: %3d        Whole size: %.1f MB'
      end
      object LLLPathChange14: TLabel
        Left = 16
        Top = 248
        Width = 293
        Height = 13
        Caption = 'Deleting files in previous folder. Remaining number of files %8d'
      end
      object LLLPathChange15: TLabel
        Left = 16
        Top = 264
        Width = 126
        Height = 13
        Caption = 'Couldn'#39't create new folder!'
      end
      object LLLPathChange16: TLabel
        Left = 16
        Top = 280
        Width = 99
        Height = 13
        Caption = 'New folder is absent!'
      end
      object LLLPathChange17: TLabel
        Left = 16
        Top = 296
        Width = 511
        Height = 13
        Caption = 
          '     The setting of a new folder is not possible.\#Other Media S' +
          'uite instances are launched on the computers:'
      end
      object LLLPathChange18: TLabel
        Left = 16
        Top = 312
        Width = 166
        Height = 13
        Caption = 'Total number of checked files: %3d'
      end
      object LLLPathChange19: TLabel
        Left = 16
        Top = 328
        Width = 231
        Height = 13
        Caption = 'File "%s" is not found!\#Continue files checking?'
      end
      object LLLPathChange20: TLabel
        Left = 16
        Top = 344
        Width = 193
        Height = 13
        Caption = 'Some files are not found in current folder.'
      end
      object LLLPathChange21: TLabel
        Left = 16
        Top = 360
        Width = 180
        Height = 13
        Caption = 'Some files are not found in new folder.'
      end
      object LLLPathChange22: TLabel
        Left = 16
        Top = 376
        Width = 180
        Height = 13
        Caption = '%d files are not found in current folder.'
      end
      object LLLPathChange23: TLabel
        Left = 16
        Top = 392
        Width = 167
        Height = 13
        Caption = '%d files are not found in new folder.'
      end
      object LLLPathChange24: TLabel
        Left = 16
        Top = 408
        Width = 191
        Height = 13
        Caption = 'Are you sure you want to change folder?'
      end
      object LLLPathChange25: TLabel
        Left = 16
        Top = 424
        Width = 99
        Height = 13
        Caption = 'New folder is not set.'
      end
      object LLLPathChange26: TLabel
        Left = 16
        Top = 440
        Width = 95
        Height = 13
        Caption = 'Files were checked.'
      end
      object LLLPathChange27: TLabel
        Left = 16
        Top = 456
        Width = 81
        Height = 13
        Caption = 'New folder is set.'
      end
      object LLLPathChange28: TLabel
        Left = 16
        Top = 472
        Width = 257
        Height = 13
        Caption = 'Image Files Root Folder changing should be continued'
      end
      object LLLPathChange29: TLabel
        Left = 16
        Top = 488
        Width = 255
        Height = 13
        Caption = 'Video Files Root Folder changing should be continued'
      end
      object LLLPathChange30: TLabel
        Left = 16
        Top = 504
        Width = 284
        Height = 13
        Caption = 'Video Files Client Root Folder changing should be continued'
      end
      object LLLPathChange31: TLabel
        Left = 16
        Top = 520
        Width = 174
        Height = 13
        Caption = 'Image Files Root Folder is undefined!'
      end
      object LLLPathChange32: TLabel
        Left = 16
        Top = 536
        Width = 201
        Height = 13
        Caption = 'Video Files Client Root Folder is undefined!'
      end
      object LLLPathChange33: TLabel
        Left = 16
        Top = 552
        Width = 172
        Height = 13
        Caption = 'Video Files Root Folder is undefined!'
      end
      object LLLPathChange34: TLabel
        Left = 16
        Top = 568
        Width = 125
        Height = 13
        Caption = 'Change Image Files Folder'
      end
      object LLLPathChange35: TLabel
        Left = 16
        Top = 584
        Width = 123
        Height = 13
        Caption = 'Change Video Files Folder'
      end
      object LLLPathChange36: TLabel
        Left = 16
        Top = 600
        Width = 242
        Height = 13
        Caption = 'Total number of files: %3d        Whole size: %.1f MB'
      end
      object LLLPathChange37: TLabel
        Left = 16
        Top = 616
        Width = 277
        Height = 13
        Caption = 'Total number of moved files: %3d        Whole size: %.1f MB'
      end
      object LLLPathChange38: TLabel
        Left = 16
        Top = 632
        Width = 116
        Height = 13
        Caption = 'Total number of files:    0'
      end
      object LLLPathChange39: TLabel
        Left = 16
        Top = 648
        Width = 273
        Height = 13
        Caption = 'Deleting files in new folder. Remaining number of files %8d'
      end
      object LLLSysErrMes: TLabel
        Left = 12
        Top = 8
        Width = 1218
        Height = 13
        Caption = 
          'The software has encountered a system error.\#Please try to rest' +
          'art the software. In case the software\#does not start, reboot y' +
          'our computer and try to start it.\#In case you have this error a' +
          'gain please call the support.\#             Click OK to close th' +
          'e software.'
      end
      object LLLSlidesLock1: TLabel
        Left = 16
        Top = 688
        Width = 133
        Height = 13
        Caption = 'Objects access confirmation'
      end
      object LLLSlidesLock2: TLabel
        Left = 16
        Top = 704
        Width = 411
        Height = 13
        Caption = 
          'The selected object is at the other location.\#It can be accesse' +
          'd by %s only. Proceed?'
      end
      object LLLSlidesLock3: TLabel
        Left = 16
        Top = 720
        Width = 435
        Height = 13
        Caption = 
          'The selected objects are at other location(s).\#They can be acce' +
          'ssed by %s only. Proceed?'
      end
      object LLLSlidesLock4: TLabel
        Left = 16
        Top = 736
        Width = 259
        Height = 13
        Caption = ' %d Media object(s) have been deleted by other user(s)'
      end
      object LLLPrepVideoFile1: TLabel
        Left = 16
        Top = 760
        Width = 136
        Height = 13
        Caption = 'Video File %s is inaccessible!'
      end
      object LLLPrepVideoFile2: TLabel
        Left = 16
        Top = 776
        Width = 177
        Height = 13
        Caption = 'May be it is allocated on computer %s'
      end
      object LLLLinkCLFSetup1: TLabel
        Left = 352
        Top = 72
        Width = 163
        Height = 13
        Caption = 'Wrong Link Command Line Format'
      end
      object LLLLinkCLFSetup2: TLabel
        Left = 352
        Top = 88
        Width = 304
        Height = 13
        Caption = 'Please confirm you wish to change the link command line format.'
      end
      object LLLLinkCLFSetup3: TLabel
        Left = 352
        Top = 104
        Width = 467
        Height = 13
        Caption = 
          'You defined the command line as \#%s.\#            Press OK to s' +
          'ave it or Cancel to continue editing.'
      end
      object LLLLinks1: TLabel
        Left = 16
        Top = 808
        Width = 267
        Height = 13
        Caption = 'The file with link parameters "%s" is missing or corrupted.'
      end
      object LLLLinks2: TLabel
        Left = 16
        Top = 824
        Width = 173
        Height = 13
        Caption = 'Patient Surname is missing in the file.'
      end
      object LLLLinks3: TLabel
        Left = 16
        Top = 840
        Width = 209
        Height = 13
        Caption = 'User defined Command Line is not specified.'
      end
      object LLLLinks4: TLabel
        Left = 16
        Top = 856
        Width = 223
        Height = 13
        Caption = 'Value for last command line key "%s" is absent.'
      end
      object LLLLinks5: TLabel
        Left = 16
        Top = 872
        Width = 189
        Height = 13
        Caption = 'Wrong command line key "%s" is found.'
      end
      object LLLLinks6: TLabel
        Left = 16
        Top = 888
        Width = 373
        Height = 13
        Caption = 
          'Wrong user defined command line format in position %d near key "' +
          '%s" is found.'
      end
      object LLLLinks7: TLabel
        Left = 16
        Top = 904
        Width = 252
        Height = 13
        Caption = 'Wrong user defined value "%s" for key "%s" is found.'
      end
      object LLLGAEnter1: TLabel
        Left = 416
        Top = 808
        Width = 199
        Height = 13
        Caption = 'The Global Administrator session is ended.'
      end
      object LLLGAEnter2: TLabel
        Left = 416
        Top = 824
        Width = 390
        Height = 13
        Caption = 
          'Global administration mode is set by another user.\#            ' +
          '   Please try again later.'
      end
      object LLLGAEnter3: TLabel
        Left = 416
        Top = 840
        Width = 180
        Height = 13
        Caption = 'You are in Global administration mode.'
      end
      object LLLClientSetup1: TLabel
        Left = 640
        Top = 328
        Width = 240
        Height = 13
        Caption = 'Wrong Remote Client Device Context saving mode'
      end
      object LLLClientSetup2: TLabel
        Left = 640
        Top = 344
        Width = 352
        Height = 13
        Caption = 
          'New Device profile context will be applied after Centaur Media S' +
          'uite restart'
      end
      object LLLClientSetup3: TLabel
        Left = 640
        Top = 360
        Width = 553
        Height = 13
        AutoSize = False
        Caption = 
          'You are about to change the Device profile context for all remot' +
          'e users.\#This might require the subsequent device installations' +
          ' for them.\#                Are you still willing to proceed?'
      end
      object LLLSAModeSetup: TLabel
        Left = 640
        Top = 392
        Width = 286
        Height = 13
        Caption = 'Please confirm you wish to change the software alone mode.'
      end
      object LLLPolyline1: TLabel
        Left = 224
        Top = 760
        Width = 333
        Height = 13
        Caption = 
          'This object is not calibrated. Please do the calibration of this' +
          ' object first'
      end
      object LLLPolyline2: TLabel
        Left = 224
        Top = 776
        Width = 856
        Height = 13
        Caption = 
          'This object has been imported from the external source. The meas' +
          'urement can be inaccurate. To guarantee the accurate measurement' +
          ' it is recommended to calibrate this object first. '
      end
      object LLLConvImgToBMP2: TLabel
        Left = 496
        Top = 544
        Width = 122
        Height = 13
        Caption = 'File has not proper format '
      end
      object LLLConvImgToBMP3: TLabel
        Left = 496
        Top = 560
        Width = 84
        Height = 13
        Caption = 'Couldn'#39't open file '
      end
      object LLLConvImgToBMP4: TLabel
        Left = 496
        Top = 576
        Width = 199
        Height = 13
        Caption = 'Open file error. Try to continue convertion.'
      end
      object LLLConvImgToBMP1: TLabel
        Left = 496
        Top = 528
        Width = 100
        Height = 13
        Caption = 'Image file conversion'
      end
      object LLLConvImgToBMP5: TLabel
        Left = 496
        Top = 592
        Width = 136
        Height = 13
        Caption = ' %d of %d files are converted'
      end
      object LLLRefreshSlides1: TLabel
        Left = 712
        Top = 408
        Width = 176
        Height = 13
        Caption = ' %d new object(s) have been created'
      end
      object LLLRefreshSlides2: TLabel
        Left = 712
        Top = 424
        Width = 152
        Height = 13
        Caption = ' %d object(s) have been deleted'
      end
      object LLLRefreshSlides3: TLabel
        Left = 712
        Top = 440
        Width = 159
        Height = 13
        Caption = ' %d object(s) have been changed'
      end
      object LLLRefreshSlides4: TLabel
        Left = 712
        Top = 456
        Width = 262
        Height = 13
        Caption = 'Media objects list was changed by other user(s) activity.'
      end
      object LLLRefreshSlides5: TLabel
        Left = 712
        Top = 472
        Width = 443
        Height = 13
        Caption = 
          ' %d opened Media object(s) were updated because they have been c' +
          'hanged by other user(s) '
      end
      object LLLCalibrate: TLabel
        Left = 328
        Top = 632
        Width = 198
        Height = 13
        Caption = 'Resolution should be between %g and %g'
      end
      object LLLCalibrate1: TLabel
        Left = 328
        Top = 648
        Width = 135
        Height = 13
        Caption = '   Enter length of the Polyline'
      end
      object LLLCalibrate2: TLabel
        Left = 328
        Top = 664
        Width = 119
        Height = 13
        Caption = '   Enter length of the Line'
      end
      object LLLDevProfile1: TLabel
        Left = 744
        Top = 32
        Width = 192
        Height = 13
        Caption = 'Selected device profile "%s" is corrupted'
      end
      object LLLDevProfile2: TLabel
        Left = 744
        Top = 48
        Width = 260
        Height = 13
        Caption = 'Capture devices are not found. Profile will not be saved'
      end
      object LLLDevProfile3: TLabel
        Left = 744
        Top = 64
        Width = 281
        Height = 13
        Caption = 'The '#39'%s'#39' profile already exists.\#Please enter another name.'
      end
      object LLLDevProfile4: TLabel
        Left = 744
        Top = 80
        Width = 65
        Height = 13
        Caption = 'TWAIN mode'
      end
      object LLLCheckVideoFile1: TLabel
        Left = 720
        Top = 512
        Width = 537
        Height = 13
        AutoSize = False
        Caption = 
          'The media object file "%s" is missing\#in the folder "%s"\#Pleas' +
          'e check your folder name and try again.'
      end
      object LLLCheckVideoFile2: TLabel
        Left = 720
        Top = 528
        Width = 545
        Height = 13
        AutoSize = False
        Caption = 
          'The media object ID %s is corrupted and cannot be open. The corr' +
          'upted file name is\#"%s"\#Please check the file system on your S' +
          'erver PC.'
      end
      object LLLFreeSpaceWarn1: TLabel
        Left = 720
        Top = 576
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 'You have %s Hard Drive space only available on your Server %s'
      end
      object LLLFreeSpaceWarn2: TLabel
        Left = 720
        Top = 592
        Width = 400
        Height = 13
        AutoSize = False
        Caption = 
          'The software requires minimum 500.00Mb of free space to operate.' +
          '\#Please free up more space on your Server PC Hard Drive and res' +
          'tart CMS.'
      end
      object LLLSlidesDel1: TLabel
        Left = 872
        Top = 112
        Width = 247
        Height = 13
        Caption = ' %d Media object(s) have been used by other user(s)'
      end
      object LLLSlidesDel2: TLabel
        Left = 872
        Top = 128
        Width = 223
        Height = 13
        Caption = ' %d Media object(s) are from another location(s)'
      end
      object LLLSlidesDel3: TLabel
        Left = 872
        Top = 144
        Width = 251
        Height = 13
        Caption = ' %d Media object(s) were created on other computers'
      end
      object LLLSlidesDel4: TLabel
        Left = 872
        Top = 160
        Width = 253
        Height = 13
        Caption = ' %d media object(s) to delete is needed ... Please wait'
      end
      object LLLSlidesDel5: TLabel
        Left = 872
        Top = 176
        Width = 155
        Height = 13
        Caption = ' %d media object(s) were deleted'
      end
      object LLLDupl1: TLabel
        Left = 952
        Top = 216
        Width = 199
        Height = 13
        Caption = ' Duplicating media object(s) ... Please wait'
      end
      object LLLDupl2: TLabel
        Left = 952
        Top = 232
        Width = 73
        Height = 13
        Caption = ' %d of %d done'
      end
      object LLLDupl3: TLabel
        Left = 952
        Top = 248
        Width = 145
        Height = 13
        Caption = 'Media Object (ID %s) duplicate'
      end
      object LLLDupl4: TLabel
        Left = 952
        Top = 264
        Width = 212
        Height = 13
        Caption = '%d study object(s) of %d object(s) are skiped!'
      end
      object LLLFileImport1: TLabel
        Left = 872
        Top = 656
        Width = 90
        Height = 13
        Caption = 'File %s is not found'
      end
      object LLLFileImport2: TLabel
        Left = 872
        Top = 672
        Width = 202
        Height = 13
        Caption = 'File %s has not implemented DICOM format'
      end
      object LLLFileImport3: TLabel
        Left = 872
        Top = 688
        Width = 117
        Height = 13
        Caption = 'File %s has invalid format'
      end
      object LLLVideoExport: TLabel
        Left = 480
        Top = 704
        Width = 161
        Height = 13
        Caption = 'Exported Video File %s is absent!!!'
      end
      object LLLDemoConstraints1: TLabel
        Left = 720
        Top = 616
        Width = 464
        Height = 13
        Caption = 
          'You have already created %d Media Objects.\#You are not allowed ' +
          'to create more Media Objects.'
      end
      object LLLDemoConstraints2: TLabel
        Left = 720
        Top = 632
        Width = 459
        Height = 13
        Caption = 
          'You have already created %d Media Objects.\#You are allowed to c' +
          'reate only %d Media Objects.'
      end
      object LLLImportNotes: TLabel
        Left = 656
        Top = 703
        Width = 167
        Height = 13
        Caption = 'File %s doesn'#39't contain proper data.'
      end
      object LLLFileImport5: TLabel
        Left = 872
        Top = 704
        Width = 232
        Height = 13
        Caption = 'Importing media %d object(s) of %d ... Please wait'
      end
      object LLLConvImgToBMP6: TLabel
        Left = 496
        Top = 608
        Width = 93
        Height = 13
        Caption = 'File convertion fails '
      end
      object LLLCheckVideoFile3: TLabel
        Left = 720
        Top = 544
        Width = 545
        Height = 13
        AutoSize = False
        Caption = 
          'Access to "%s" is denied.\#Any changes to the object cannot be s' +
          'aved. Press OK to continue.'
      end
      object LLLCheckVideoFile4: TLabel
        Left = 719
        Top = 560
        Width = 545
        Height = 13
        AutoSize = False
        Caption = 
          'New object cannot be saved. You will see this object in the not ' +
          'saved objects list at the next software start. Press OK to conti' +
          'nue.'
      end
      object LLLCheckImg3DFolder1: TLabel
        Left = 719
        Top = 496
        Width = 537
        Height = 13
        AutoSize = False
        Caption = 
          'The 3D object folder "%s" is missing\#in the folder "%s"\#Please' +
          ' check your folder name and try again.'
      end
      object LLLPathChange40: TLabel
        Left = 16
        Top = 664
        Width = 191
        Height = 13
        Caption = '3D Image Files Root Folder is undefined!'
      end
      object LLLExpProcTexts: TComboBox
        Left = 331
        Top = 424
        Width = 145
        Height = 113
        AutoComplete = False
        Style = csSimple
        TabOrder = 0
        Text = 'ExpProcTexts'
        Visible = False
        Items.Strings = (
          'Exporting practices ...'
          'Exporting dentists ...'
          'Export %6d patients (%5.1f%%) ...'
          'Link patients %5.1f%% ...'
          'Process %s step %d'
          'Change Export folder')
      end
      object LLLExpColNames: TComboBox
        Left = 331
        Top = 328
        Width = 137
        Height = 81
        AutoComplete = False
        Style = csSimple
        TabOrder = 1
        Text = 'ExpColNames'
        Visible = False
        Items.Strings = (
          'Total'
          'Not exported'
          'Exported'
          'Synchronized')
      end
      object LLLExpImpRowNames: TComboBox
        Left = 331
        Top = 536
        Width = 113
        Height = 73
        AutoComplete = False
        Style = csSimple
        TabOrder = 2
        Text = 'ExpImpRowNames'
        Visible = False
        Items.Strings = (
          'Patients'
          'Dentists'
          'Practices')
      end
      object LLLImpColNames: TComboBox
        Left = 483
        Top = 328
        Width = 137
        Height = 77
        AutoComplete = False
        Style = csSimple
        TabOrder = 3
        Text = 'ImpColNames'
        Visible = False
        Items.Strings = (
          'Total'
          'Imported'
          'Updated'
          'Created')
      end
      object LLLImpProcTexts: TComboBox
        Left = 491
        Top = 424
        Width = 193
        Height = 97
        AutoComplete = False
        Style = csSimple
        TabOrder = 4
        Text = 'ImpProcTexts'
        Visible = False
        Items.Strings = (
          'Importing practices ...'
          'Importing dentists ...'
          'Import %6d patients (%5.1f%%) ...'
          'Updating the existing patients ...'
          'Creating new patients ...')
      end
    end
    object TabSheet4: TTabSheet
      Caption = '_4'
      ImageIndex = 3
      object LLLCaptHandler1: TLabel
        Left = 8
        Top = 8
        Width = 500
        Height = 13
        AutoSize = False
        Caption = 
          'The Images folder is not accessible. Capture is not possible bec' +
          'ause images cannot be saved.\#Please check network connection, p' +
          'ermission to access the Images folder and start Capture again.'
      end
      object LLLCaptHandler2: TLabel
        Left = 8
        Top = 24
        Width = 126
        Height = 13
        Caption = 'Mode %s not implemented!'
      end
      object LLLCaptHandler3: TLabel
        Left = 8
        Top = 40
        Width = 250
        Height = 13
        Caption = 'Bad device Profile. Please delete it and create again.'
      end
      object LLLCaptHandler4: TLabel
        Left = 8
        Top = 56
        Width = 236
        Height = 13
        Caption = 'Capture Device Service Object %s is not found.\#'
      end
      object LLLCaptHandler5: TLabel
        Left = 8
        Top = 72
        Width = 922
        Height = 13
        Caption = 
          'The Video folder is not accessible. Capture is not possible beca' +
          'use video files cannot be saved.\#Please check network connectio' +
          'n, permission to access the Video folder and start Capture again' +
          '.'
      end
      object LLLCaptHandler6: TLabel
        Left = 8
        Top = 88
        Width = 173
        Height = 13
        Caption = 'Unexpected DirectShow Error1 = %d'
      end
      object LLLCaptHandler7: TLabel
        Left = 8
        Top = 104
        Width = 182
        Height = 13
        Caption = 'No Video Capturing Devices available!'
      end
      object LLLCaptHandler8: TLabel
        Left = 8
        Top = 120
        Width = 112
        Height = 13
        Caption = 'Process Output from %s'
      end
      object LLLCaptHandler9: TLabel
        Left = 8
        Top = 136
        Width = 214
        Height = 13
        Caption = 'Video Capturing Device "%s" is not available!'
      end
      object LLLCaptHandler10: TLabel
        Left = 8
        Top = 152
        Width = 128
        Height = 13
        Caption = 'Process Output from Import'
      end
      object LLLCaptHandler11: TLabel
        Left = 8
        Top = 168
        Width = 140
        Height = 13
        Caption = 'Process Import from Clipboard'
      end
      object LLLCaptHandler12: TLabel
        Left = 8
        Top = 184
        Width = 169
        Height = 13
        Caption = 'Process Output from X-Ray/TWAIN'
      end
      object LLLCaptHandler13: TLabel
        Left = 8
        Top = 200
        Width = 154
        Height = 13
        Caption = ' %d media object(s) are captured'
      end
      object LLLCaptHandler14: TLabel
        Left = 8
        Top = 216
        Width = 135
        Height = 13
        Caption = ' %d media object(s) acquired'
      end
      object LLLCaptHandler15: TLabel
        Left = 8
        Top = 232
        Width = 44
        Height = 13
        Caption = 'Clipboard'
      end
      object LLLAddToOpened1: TLabel
        Left = 8
        Top = 256
        Width = 126
        Height = 13
        Caption = 'This object is already open'
      end
      object LLLAddToOpened2: TLabel
        Left = 8
        Top = 272
        Width = 265
        Height = 13
        Caption = ' Media object opened in this mode couldn'#39't be changed.'
      end
      object LLLAddToOpened3: TLabel
        Left = 8
        Top = 288
        Width = 535
        Height = 13
        Caption = 
          ' Media object is marked as deleted. It couldn'#39't be changed.\# Pl' +
          'ease restore it'#39's state first if you wish to change it.'
      end
      object LLLAddToOpened4: TLabel
        Left = 8
        Top = 304
        Width = 402
        Height = 13
        Caption = 
          ' Media object is opened by other user(s).\# Any changes made to ' +
          'it will not be saved.'
      end
      object LLLAddToOpened5: TLabel
        Left = 8
        Top = 320
        Width = 930
        Height = 13
        Caption = 
          ' Media object is from another location.\# Any changes made to it' +
          ' will not be saved.\# Any changes made to it will not be saved.\' +
          '# Please duplicate the object first\# if you wish to save the ch' +
          'anges.'
      end
      object LLLSelProv1: TLabel
        Left = 579
        Top = 105
        Width = 231
        Height = 13
        Caption = 'Dentist is not selected. Select Dentist before exit.'
      end
      object LLLSelProv2: TLabel
        Left = 579
        Top = 121
        Width = 264
        Height = 13
        Caption = 'Current Dentist was deleted. Select new current Dentist.'
      end
      object LLLSelProv3: TLabel
        Left = 579
        Top = 137
        Width = 215
        Height = 13
        Caption = 'This dentist is now being edited by other user.'
      end
      object LLLSelProv4: TLabel
        Left = 579
        Top = 153
        Width = 461
        Height = 13
        Caption = 
          'This dentist couldn'#39't be deleted. It is linked to corresponding ' +
          'Practice Management System object.'
      end
      object LLLSelProv5: TLabel
        Left = 579
        Top = 169
        Width = 479
        Height = 13
        Caption = 
          '%s %s %s is linked to patient files. Please change the Dentist n' +
          'ame for these patients first, then delete.'
      end
      object LLLSelProv6: TLabel
        Left = 579
        Top = 185
        Width = 239
        Height = 13
        Caption = 'Please confirm you wish to delete dentist %s %s %s'
      end
      object LLLSelProv7: TLabel
        Left = 579
        Top = 201
        Width = 243
        Height = 13
        Caption = 'This dentist has been already deleted by other user.'
      end
      object LLLSelProv8: TLabel
        Left = 579
        Top = 217
        Width = 201
        Height = 13
        Caption = 'This dentist is controled by other user now.'
      end
      object LLLSelProv9: TLabel
        Left = 579
        Top = 233
        Width = 299
        Height = 13
        Caption = 'Please confirm you wish to permanently delete dentist %s %s %s'
      end
      object LLLSelProv10: TLabel
        Left = 579
        Top = 249
        Width = 246
        Height = 13
        Caption = 'This dentist has been already restored by other user.'
      end
      object LLLSelProv11: TLabel
        Left = 579
        Top = 265
        Width = 58
        Height = 13
        Caption = 'New Dentist'
      end
      object LLLSelProv12: TLabel
        Left = 579
        Top = 281
        Width = 67
        Height = 13
        Caption = 'Modify Dentist'
      end
      object LLLSelProv13: TLabel
        Left = 579
        Top = 297
        Width = 66
        Height = 13
        Caption = 'Dentist details'
      end
      object LLLECache1: TLabel
        Left = 8
        Top = 352
        Width = 801
        Height = 13
        Caption = 
          '    Last session of the software was terminated abnormally.\#Fil' +
          'es for unsaved object ID=%s have not proper format.\#    Press Y' +
          'es to remove files for this unsaved object?'
      end
      object LLLECache2: TLabel
        Left = 8
        Top = 368
        Width = 496
        Height = 13
        Caption = 
          'The selected object have been already changed by other user\#   ' +
          '    Are you sure you want to replace it?'
      end
      object LLLECache3: TLabel
        Left = 8
        Top = 384
        Width = 317
        Height = 13
        Caption = 
          'Do you confirm that you really want to delete\#the selected obje' +
          'ct?'
      end
      object LLLECache4: TLabel
        Left = 8
        Top = 400
        Width = 130
        Height = 13
        Caption = 'Unsaved object(s) recovery'
      end
      object LLLECache5: TLabel
        Left = 8
        Top = 416
        Width = 101
        Height = 13
        Caption = '   It was deleted later.'
      end
      object LLLECache6: TLabel
        Left = 8
        Top = 432
        Width = 188
        Height = 13
        Caption = 'New Object created at %s.   Source=%s'
      end
      object LLLECache7: TLabel
        Left = 8
        Top = 448
        Width = 194
        Height = 13
        Caption = '   It is now used and cannot be changed.'
      end
      object LLLECache8: TLabel
        Left = 8
        Top = 464
        Width = 142
        Height = 13
        Caption = 'Object state was saved at %s.'
      end
      object LLLECache9: TLabel
        Left = 8
        Top = 480
        Width = 108
        Height = 13
        Caption = '   It was '#1089'hanged later.'
      end
      object LLLECache10: TLabel
        Left = 8
        Top = 496
        Width = 121
        Height = 13
        Caption = 'Created: %s\#Source: %s'
      end
      object LLLECache11: TLabel
        Left = 8
        Top = 512
        Width = 171
        Height = 13
        Caption = 'Last modification by current user: %s'
      end
      object LLLECache12: TLabel
        Left = 8
        Top = 528
        Width = 161
        Height = 13
        Caption = 'Has already been deleted by now.'
      end
      object LLLECache13: TLabel
        Left = 8
        Top = 544
        Width = 135
        Height = 13
        Caption = 'Is now being modified by %s.'
      end
      object LLLECache14: TLabel
        Left = 8
        Top = 560
        Width = 131
        Height = 13
        Caption = 'Last modification: %s by %s.'
      end
      object LLLECache15: TLabel
        Left = 8
        Top = 576
        Width = 141
        Height = 13
        Caption = 'Object properties / Diagnoses'
      end
      object LLLAppInit1: TLabel
        Left = 240
        Top = 416
        Width = 506
        Height = 13
        Caption = 
          'It is highly recommended to free up more space before starting C' +
          'MS.\#            Do you still want to proceed?'
      end
      object LLLAppInit2: TLabel
        Left = 240
        Top = 432
        Width = 242
        Height = 13
        Caption = 'Database version does not match Enterprise Mode.'
      end
      object LLLAppInit3: TLabel
        Left = 240
        Top = 448
        Width = 295
        Height = 13
        Caption = 'Database code page %d does not match D4W code page %d.'
      end
      object LLLAppInit4: TLabel
        Left = 240
        Top = 464
        Width = 244
        Height = 13
        Caption = 'The software is now unusable. Click OK to continue'
      end
      object LLLAppInit5: TLabel
        Left = 240
        Top = 480
        Width = 168
        Height = 13
        Caption = 'Database is not in Enterprise Mode.'
      end
      object LLLAppInit6: TLabel
        Left = 240
        Top = 496
        Width = 151
        Height = 13
        Caption = 'Enterprise Mode is unregistered.'
      end
      object LLLAppInit7: TLabel
        Left = 240
        Top = 512
        Width = 234
        Height = 13
        Caption = 'Application instance is already running on this PC.'
      end
      object LLLAppInit8: TLabel
        Left = 240
        Top = 528
        Width = 518
        Height = 13
        Caption = 
          'The connection to the database server has been lost. Please rest' +
          'art your database server and the application.'
      end
      object LLLAppInit18: TLabel
        Left = 240
        Top = 688
        Width = 292
        Height = 13
        Caption = 'The software is now unusable. Click OK to close the software.'
      end
      object LLLAppInit9: TLabel
        Left = 240
        Top = 544
        Width = 200
        Height = 13
        Caption = 'The software trial period is already expired.'
      end
      object LLLAppInit10: TLabel
        Left = 240
        Top = 560
        Width = 500
        Height = 13
        AutoSize = False
        Caption = 
          'The system has detected that the software is registered for (#L#' +
          ') user license(s).\#You currently have (#L#) users. Your CIN is:' +
          ' (#ID#).\#To purchase additional licenses please call (#N#)\# on' +
          ' (#PH#) or email to (#E#) for a registration code.'
      end
      object LLLAppInit11: TLabel
        Left = 240
        Top = 576
        Width = 307
        Height = 13
        Caption = 'The software build number (%s) does not match database version'
      end
      object LLLAppInit12: TLabel
        Left = 240
        Top = 592
        Width = 322
        Height = 13
        Caption = 
          'Client build number (%s) does not match database build number (%' +
          's).'
      end
      object LLLAppInit13: TLabel
        Left = 240
        Top = 608
        Width = 252
        Height = 13
        Caption = 'The application is started in database recovery mode.'
      end
      object LLLAppInit14: TLabel
        Left = 240
        Top = 624
        Width = 284
        Height = 13
        Caption = 'Application should be started with command line parameters.'
      end
      object LLLAppInit15: TLabel
        Left = 240
        Top = 640
        Width = 286
        Height = 13
        Caption = 'Database code page %d does not match link code page %d.'
      end
      object LLLAppInit16: TLabel
        Left = 240
        Top = 656
        Width = 114
        Height = 13
        Caption = 'The patient ID is invalid.'
      end
      object LLLAppInit17: TLabel
        Left = 240
        Top = 672
        Width = 497
        Height = 13
        Caption = 
          'Sorry, you do not have access rights to use the software.\#     ' +
          '     Please talk to your system administrator.'
      end
      object LLLStudy1: TLabel
        Left = 8
        Top = 720
        Width = 99
        Height = 13
        Caption = 'New study is created'
      end
      object LLLStudy2: TLabel
        Left = 8
        Top = 736
        Width = 400
        Height = 13
        Caption = 
          'This study is currently being modified by another user. Please r' +
          'epeat your action later.'
      end
      object LLLStudy3: TLabel
        Left = 8
        Top = 752
        Width = 320
        Height = 13
        Caption = 
          'This study was changed by another user. Please repeat your actio' +
          'n.'
      end
      object LLLStudy4: TLabel
        Left = 8
        Top = 768
        Width = 603
        Height = 13
        Caption = 
          'There is already an image in this template position. Do you want' +
          ' to Dismount the current image and replace it with the new one? '
      end
      object LLLStudy5: TLabel
        Left = 8
        Top = 784
        Width = 483
        Height = 13
        Caption = 
          'The study is locked by another user. The objects will be saved o' +
          'utside the study. Click OK to continue.'
      end
      object LLLStudyNameNone: TLabel
        Left = 8
        Top = 704
        Width = 26
        Height = 13
        Caption = 'None'
      end
      object LLLECache16: TLabel
        Left = 8
        Top = 592
        Width = 158
        Height = 13
        Caption = 'Image Data has not proper format'
      end
      object LLLAppInit19: TLabel
        Left = 240
        Top = 704
        Width = 260
        Height = 13
        Caption = 'After you click OK the upgrade process will commence.'
      end
      object LLLStudy6: TLabel
        Left = 8
        Top = 800
        Width = 339
        Height = 13
        Caption = 
          'The study is locked by another user. Please resume your operatio' +
          'n later.'
      end
      object LLLStudy7: TLabel
        Left = 8
        Top = 816
        Width = 507
        Height = 13
        Caption = 
          'This study position contains image(s). Would you like to dismoun' +
          't them all and replace with the new one(s)? '
      end
      object LLLStudyColorsList: TComboBox
        Left = 944
        Top = 382
        Width = 157
        Height = 99
        AutoComplete = False
        Style = csSimple
        TabOrder = 0
        Text = 'StudyColorsList'
        Visible = False
        Items.Strings = (
          'None'
          'Green'
          'Blue'
          'Red'
          'Yellow')
      end
      object LLLExpFileNameParts: TComboBox
        Left = 768
        Top = 382
        Width = 157
        Height = 67
        AutoComplete = False
        Style = csSimple
        TabOrder = 1
        Text = 'ExpFileNameParts'
        Visible = False
        Items.Strings = (
          'DOB'
          'Taken'
          'Chart')
      end
      object LLLFixMediaTypes: TComboBox
        Left = 768
        Top = 462
        Width = 157
        Height = 43
        AutoComplete = False
        Style = csSimple
        TabOrder = 2
        Text = 'FixMediaTypes'
        Visible = False
        Items.Strings = (
          'Unassigned')
      end
      object LLLIniMediaTypes: TComboBox
        Left = 768
        Top = 507
        Width = 157
        Height = 123
        AutoComplete = False
        Style = csSimple
        TabOrder = 3
        Text = 'IniMediaTypes'
        Visible = False
        Items.Strings = (
          'Cephalometric'
          'Intraoral'
          'Intraoral Camera'
          'Panoramic'
          'Digital Photo'#8217's'
          'Documents')
      end
      object LLLPrintPageTexts: TComboBox
        Left = 768
        Top = 638
        Width = 157
        Height = 59
        AutoComplete = False
        Style = csSimple
        TabOrder = 4
        Text = 'PrintPageTexts'
        Visible = False
        Items.Strings = (
          'Page Header'
          
            'Printed: (#PrintDate#) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp' +
            ';&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb' +
            'sp; Page (#PageNumber#) of (#PageCount#)')
      end
      object LLLPrintSlideTexts: TComboBox
        Left = 768
        Top = 702
        Width = 157
        Height = 59
        AutoComplete = False
        Style = csSimple
        TabOrder = 5
        Text = 'PrintSlideTexts'
        Visible = False
        Items.Strings = (
          'SlideHeader=(#SlideDTTaken#) (ID: (#SlideID#))'
          'SlideFooter=Slide Footer')
      end
    end
    object TabSheet5: TTabSheet
      Caption = '_5'
      ImageIndex = 4
      object LLLRegister1: TLabel
        Left = 8
        Top = 16
        Width = 423
        Height = 13
        Caption = 
          'You entered incorrect the software Registration Code.\#         ' +
          '                     Please reenter'
      end
      object LLLRegister2: TLabel
        Left = 8
        Top = 32
        Width = 492
        Height = 13
        Caption = 
          'You have exceeded the number of users currently registered.\#   ' +
          '                 The software will close now.'
      end
      object LLLRegister3: TLabel
        Left = 8
        Top = 48
        Width = 209
        Height = 13
        Caption = 'System registration parameters are changed.'
      end
      object LLLRegister4: TLabel
        Left = 8
        Top = 64
        Width = 128
        Height = 13
        Caption = 'Please restart the software.'
      end
      object LLLRegister5: TLabel
        Left = 8
        Top = 80
        Width = 238
        Height = 13
        Caption = ' The software registration is started. Wait please ...'
      end
      object LLLRegister6: TLabel
        Left = 8
        Top = 96
        Width = 406
        Height = 13
        Caption = 
          'The system has detected that the software is registered for (#LI' +
          '#)(#L#) user license(s).'
      end
      object LLLRegister7: TLabel
        Left = 8
        Top = 112
        Width = 263
        Height = 13
        Caption = 'Number of allowed connections to Database exceeded.'
      end
      object LLLRegister8: TLabel
        Left = 8
        Top = 128
        Width = 309
        Height = 13
        Caption = 'The Database Server (Computer) Identification Number is: (#ID#).'
      end
      object LLLRegister9: TLabel
        Left = 8
        Top = 144
        Width = 305
        Height = 13
        Caption = 
          'Your software build (#VN#) differs from registered build (#VNR#)' +
          '!'
      end
      object LLLRegister10: TLabel
        Left = 8
        Top = 160
        Width = 213
        Height = 13
        Caption = 'The software build is (#VNR#) (#RegType#).'
      end
      object LLLRegister11: TLabel
        Left = 8
        Top = 176
        Width = 294
        Height = 13
        Caption = 'You need to registered to use the software in Enterprise Mode.'
      end
      object LLLRegister12: TLabel
        Left = 8
        Top = 192
        Width = 281
        Height = 13
        Caption = 'The system has detected that the software is not registered.'
      end
      object LLLRegister13: TLabel
        Left = 8
        Top = 208
        Width = 364
        Height = 13
        Caption = 
          'The system will be able to work for (#TM#), after that it will b' +
          'ecome unusable.'
      end
      object LLLRegister14: TLabel
        Left = 8
        Top = 224
        Width = 200
        Height = 13
        Caption = 'The software trial period is already expired.'
      end
      object LLLRegister15: TLabel
        Left = 8
        Top = 240
        Width = 309
        Height = 13
        Caption = 'The Database Server (Computer) Identification Number is: (#ID#).'
      end
      object LLLRegister16: TLabel
        Left = 8
        Top = 256
        Width = 144
        Height = 13
        Caption = 'The software build is (#VN0#).'
      end
      object LLLRegister17: TLabel
        Left = 8
        Top = 272
        Width = 681
        Height = 13
        Caption = 
          'To purchase additional user licenses or change version type to P' +
          'rofessional please call (#N#) on (#PH#) or email to (#E#) for a ' +
          'registration code.'
      end
      object LLLRegister18: TLabel
        Left = 8
        Top = 288
        Width = 498
        Height = 13
        Caption = 
          'To purchase additional user licenses please call (#N#) on (#PH#)' +
          ' or email to (#E#) for a registration code.'
      end
      object LLLRegister19: TLabel
        Left = 8
        Top = 304
        Width = 356
        Height = 13
        Caption = 
          'To get your registration code please call (#N#) on (#PH#) or ema' +
          'il to (#E#).'
      end
      object LLLRegister20: TLabel
        Left = 8
        Top = 320
        Width = 320
        Height = 13
        Caption = 
          'To solve the problem please call (#N#) on (#PH#) or email to (#E' +
          '#).'
      end
      object LLLMPatAppTaskBar: TLabel
        Left = 8
        Top = 376
        Width = 294
        Height = 13
        Caption = '(#RegAppName#) - (#PatientFirstName#) (#PatientSurname#)'
      end
      object LLLMPatAppTitleBar: TLabel
        Left = 8
        Top = 392
        Width = 983
        Height = 13
        Caption = 
          '(#RegAppName#) - Px:[(#PatientCardNumber#)] (#PatientFirstName#)' +
          ' (#PatientSurname#)     Prv: (#ProviderTitle#) (#ProviderFirstNa' +
          'me#) (#ProviderSurname#)     Location: (#LocationID#) - (#Locati' +
          'onTitle#)'
      end
      object LLLMPatAppVIPTitleBar: TLabel
        Left = 8
        Top = 408
        Width = 978
        Height = 13
        Caption = 
          '(#RegAppName#) Enterprise       (#VIPCTitle#) (#LocationTitle#) ' +
          '   Px:[(#PatientCardNumber#)] (#PatientFirstName#) (#PatientSurn' +
          'ame#)    Prv: (#ProviderTitle#) (#ProviderFirstName#) (#Provider' +
          'Surname#)'
      end
      object LLLMPatAppLockTitleBar: TLabel
        Left = 8
        Top = 424
        Width = 183
        Height = 13
        Caption = 'Centaur Media Suite - Patient is locked'
      end
      object LLLMPatAppLockMes: TLabel
        Left = 8
        Top = 440
        Width = 905
        Height = 13
        Caption = 
          'Px: (#PatientFirstName#) (#PatientSurname#)  is locked by     Pr' +
          'v: (#ProviderTitle#) (#ProviderFirstName#) (#ProviderSurname#)  ' +
          '   Location: (#LocationTitle#)  Client: (#CLientCompVirtualID#)'
      end
      object LLLMPatMailSubject: TLabel
        Left = 8
        Top = 456
        Width = 611
        Height = 13
        Caption = 
          'Images/Media from (#ProviderTitle#) (#ProviderFirstName#) (#Prov' +
          'iderSurname#) (Px: (#PatientFirstName#) (#PatientSurname#))'
      end
      object LLLMPatPrintPatDetails1: TLabel
        Left = 8
        Top = 472
        Width = 512
        Height = 13
        Caption = 
          '(#PatientSurname#), (#PatientTitle#) (#PatientFirstName#) [(#Pat' +
          'ientCardNumber#)],  DOB: (#PatientDOB#)'
      end
      object LLLMPatPrintPatDetails2: TLabel
        Left = 8
        Top = 488
        Width = 252
        Height = 13
        Caption = 'Gender:   (#PatientGender#)   DOB:  (#PatientDOB#)'
      end
      object LLLRegister21: TLabel
        Left = 8
        Top = 336
        Width = 99
        Height = 13
        Caption = '%d hours %d minutes'
      end
      object LLLEmail1: TLabel
        Left = 8
        Top = 520
        Width = 128
        Height = 13
        Caption = ' Emailing internal exception'
      end
      object LLLEmail2: TLabel
        Left = 8
        Top = 536
        Width = 140
        Height = 13
        Caption = ' Emailing was aborted by user'
      end
      object LLLEmail3: TLabel
        Left = 8
        Top = 552
        Width = 73
        Height = 13
        Caption = ' Emailing failure'
      end
      object LLLEmail4: TLabel
        Left = 8
        Top = 568
        Width = 66
        Height = 13
        Caption = ' Emailing error'
      end
      object LLLMemory2: TLabel
        Left = 8
        Top = 632
        Width = 712
        Height = 13
        Caption = 
          'There is not enough memory to process all images. %d object(s) h' +
          'aven'#39't been attached.\#        Please close some open image(s) o' +
          'r restart the software.'
      end
      object LLLMemory1: TLabel
        Left = 8
        Top = 616
        Width = 744
        Height = 13
        Caption = 
          'There is not enough memory to process all images. %d object(s) h' +
          'aven'#39't been put to Clipboard.\#        Please close some open im' +
          'age(s) or restart the software.'
      end
      object LLLMemory3: TLabel
        Left = 8
        Top = 648
        Width = 518
        Height = 13
        Caption = 
          '     There is not enough memory to finish the action.\#Please cl' +
          'ose some open image(s) or restart the software.'
      end
      object LLLMemory4: TLabel
        Left = 8
        Top = 664
        Width = 539
        Height = 13
        Caption = 
          ' There is not enough memory to open this Media object.\#Please c' +
          'lose some open image(s) or restart the software.'
      end
      object LLLMemory5: TLabel
        Left = 8
        Top = 680
        Width = 711
        Height = 13
        Caption = 
          'There is not enough memory to process all images. %d object(s) h' +
          'aven'#39't been exported.\#        Please close some open image(s) o' +
          'r restart the software.'
      end
      object LLLMemory6: TLabel
        Left = 9
        Top = 696
        Width = 641
        Height = 13
        Caption = 
          '          There is not enough memory to import the object(s).\#P' +
          'lease close the open image(s) and repeat the import or restart t' +
          'he software.'
      end
      object LLLMemory7: TLabel
        Left = 8
        Top = 712
        Width = 338
        Height = 13
        Caption = 
          'There is not enough memory to open more than %d object(s) of thi' +
          's size.'
      end
      object LLLMemory8: TLabel
        Left = 8
        Top = 728
        Width = 719
        Height = 13
        Caption = 
          'There is not enough memory to process all images. %d object(s) h' +
          'aven'#39't been duplicated.\#        Please close some open image(s)' +
          ' or restart the software.'
      end
      object LLLMemory9: TLabel
        Left = 8
        Top = 744
        Width = 193
        Height = 13
        Caption = 'There is not enough memory to continue.'
      end
      object LLLResampleLarge1: TLabel
        Left = 504
        Top = 104
        Width = 411
        Height = 13
        Caption = 
          'Check image files size is now selected by another user\#        ' +
          '      Please try again later.'
      end
      object LLLResampleLarge2: TLabel
        Left = 504
        Top = 120
        Width = 292
        Height = 13
        Caption = 'Do you really want to break check image files size procedure?'
      end
      object LLLResampleLarge3: TLabel
        Left = 504
        Top = 136
        Width = 428
        Height = 13
        Caption = 
          'Check image files size is %s. %d of %d image(s) were processed, ' +
          '%d of %d were resampled.'
      end
      object LLLResampleLarge4: TLabel
        Left = 504
        Top = 152
        Width = 170
        Height = 13
        Caption = 'Check image files size, started at %s'
      end
      object LLLResampleLarge5: TLabel
        Left = 504
        Top = 168
        Width = 310
        Height = 13
        Caption = 'You have unsaved resample report. Press OK to save report data.'
      end
      object LLLResampleLarge0: TLabel
        Left = 504
        Top = 88
        Width = 88
        Height = 13
        Caption = '%s is resampling ...'
      end
      object LLLCreateStudyFiles1: TLabel
        Left = 168
        Top = 512
        Width = 137
        Height = 13
        Caption = ' %d study file(s) were created'
      end
      object LLLCreateStudyFiles2: TLabel
        Left = 168
        Top = 528
        Width = 459
        Height = 13
        Caption = 
          'Study files creation is %s. %d of %d media object(s) were proces' +
          'sed, %d study file(s) were created.'
      end
      object LLLCreateStudyFiles3: TLabel
        Left = 168
        Top = 544
        Width = 276
        Height = 13
        Caption = 'Do you really want to break study files creation procedure?'
      end
      object LLLCreateStudyFiles4: TLabel
        Left = 168
        Top = 560
        Width = 388
        Height = 13
        Caption = 
          'Study data fixing is now selected by another user.\#            ' +
          '  Please try again later.'
      end
      object LLLCopyMovePatData1: TLabel
        Left = 7
        Top = 792
        Width = 811
        Height = 13
        Caption = 
          'This patient data are locked now. Please wait a little and the s' +
          'oftware will continue automatically.\#               Click OK or' +
          ' close this window if you wish to select other patient.'
      end
      object LLLCopyMovePatData2: TLabel
        Left = 7
        Top = 808
        Width = 844
        Height = 13
        Caption = 
          'Some patient(s)data are locked now. Please wait a little and the' +
          ' software will continue automatically.\#               Click OK ' +
          'or close this window if you wish to stop starting procedure.'
      end
      object LLLMPatHPCommoPart: TLabel
        Left = 678
        Top = 5
        Width = 334
        Height = 13
        Caption = 
          'Px:[(#PatientCardNumber#)] (#PatientFirstName#) (#PatientSurname' +
          '#)'
      end
      object LLLMPatHPSlidePart: TLabel
        Left = 678
        Top = 21
        Width = 139
        Height = 13
        Caption = '(#ObjChart#) (#ObjDTaken#)'
      end
      object LLLMemory10: TLabel
        Left = 8
        Top = 760
        Width = 492
        Height = 13
        Caption = 
          ' There is not enough memory to preview this Media object.\#     ' +
          '  Please close the window and try again.'
      end
      object LLLIU1: TLabel
        Left = 504
        Top = 208
        Width = 255
        Height = 13
        Caption = 'Would you like to check for updates to your software?'
      end
      object LLLIUCapt: TLabel
        Left = 504
        Top = 192
        Width = 88
        Height = 13
        Caption = 'Check for update?'
      end
      object LLLEmail5: TLabel
        Left = 8
        Top = 584
        Width = 726
        Height = 13
        Caption = 
          'The secure connection cannot be established as Open SSL is not i' +
          'nstalled on your PC.\#                       Please install Open' +
          ' SSL and repeat the operation.'
      end
      object LLLCaptToStudy1: TLabel
        Left = 504
        Top = 240
        Width = 374
        Height = 13
        Caption = 
          'The image will be permanently deleted. Please click Yes to confi' +
          'rm the deletion.'
      end
      object LLLDICOM1: TLabel
        Left = 670
        Top = 45
        Width = 203
        Height = 13
        Caption = ' %d Media object(s) store process is started'
      end
      object LLLDICOM2: TLabel
        Left = 670
        Top = 61
        Width = 185
        Height = 13
        Caption = ' %d  opened media object(s) are skiped'
      end
      object LLLRegisterType: TComboBox
        Left = 529
        Top = 8
        Width = 93
        Height = 73
        AutoComplete = False
        Style = csSimple
        TabOrder = 0
        Text = 'RegisterType'
        Visible = False
        Items.Strings = (
          'Light'
          'Professional'
          'Enterprise')
      end
    end
  end
end
