inherited K_FormCMDCMImport: TK_FormCMDCMImport
  Left = 233
  Top = 333
  Width = 484
  Height = 399
  Caption = 'DICOM Import'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object LLLDCMDImport1: TLabel [0]
    Left = 328
    Top = -5
    Width = 115
    Height = 13
    Caption = ' %d Patient(s) are added'
    Visible = False
  end
  object LLLDCMDImport2: TLabel [1]
    Left = 132
    Top = -5
    Width = 192
    Height = 13
    Caption = ' %d of %d selected image(s) are imported'
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 464
    Top = 353
  end
  inline VTreeFrame: TN_VTreeFrame
    Left = 8
    Top = 8
    Width = 300
    Height = 350
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    inherited TreeView: TTreeView
      Width = 300
      Height = 350
    end
  end
  inline RFrame: TN_Rast1Frame
    Left = 318
    Top = 15
    Width = 150
    Height = 150
    HelpType = htKeyword
    Anchors = [akRight, akBottom]
    Constraints.MinHeight = 56
    Constraints.MinWidth = 56
    Color = clBtnFace
    ParentColor = False
    TabOrder = 2
    inherited PaintBox: TPaintBox
      Width = 134
      Height = 134
    end
    inherited HScrollBar: TScrollBar
      Top = 134
      Width = 150
    end
    inherited VScrollBar: TScrollBar
      Left = 134
      Height = 134
    end
  end
  object Button1: TButton
    Left = 320
    Top = 171
    Width = 145
    Height = 25
    Action = aAddMarkedPatients
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object Button2: TButton
    Left = 320
    Top = 203
    Width = 145
    Height = 25
    Action = aCheckAllMarkedObjs
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  object Button3: TButton
    Left = 320
    Top = 235
    Width = 145
    Height = 25
    Action = aUncheckAllMarkedObjs
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object Button4: TButton
    Left = 320
    Top = 267
    Width = 145
    Height = 25
    Action = aImportChecked
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object Button5: TButton
    Left = 320
    Top = 331
    Width = 145
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 7
  end
  object ChBImportToCurPatient: TCheckBox
    Left = 320
    Top = 304
    Width = 145
    Height = 17
    Action = aChangeImportToCurPatient
    Anchors = [akRight, akBottom]
    State = cbChecked
    TabOrder = 8
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 284
    object AddMarkedPatientstoMediaSuite1: TMenuItem
      Action = aAddMarkedPatients
    end
    object Checkallmarkedobjectsforimport1: TMenuItem
      Action = aCheckAllMarkedObjs
    end
    object Uncheckallmarkedobjects1: TMenuItem
      Action = aUncheckAllMarkedObjs
    end
    object Importcheckedobjects1: TMenuItem
      Action = aImportChecked
    end
  end
  object ActionList: TActionList
    Left = 168
    Top = 284
    object aAddMarkedPatients: TAction
      Caption = 'Add Patients'
      Hint = 'Add marked patients to Media Suite'
      OnExecute = aAddMarkedPatientsExecute
    end
    object aCheckAllMarkedObjs: TAction
      Caption = 'Select images'
      Hint = 'Set all marked objects checked state for future import'
      OnExecute = aCheckAllMarkedObjsExecute
    end
    object aUncheckAllMarkedObjs: TAction
      Caption = 'Unselect images'
      Hint = 'Clear images selected state to prevent future import'
      OnExecute = aUncheckAllMarkedObjsExecute
    end
    object aImportChecked: TAction
      Caption = 'Import selected images'
      Hint = 'Import all selected images to Media Suite'
      OnExecute = aImportCheckedExecute
    end
    object aChangeImportToCurPatient: TAction
      Caption = 'Import to current Patient'
      Checked = True
      OnExecute = aChangeImportToCurPatientExecute
    end
  end
end
