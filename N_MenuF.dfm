object N_MenuForm: TN_MenuForm
  Left = 153
  Top = 506
  Caption = 'N_MenuForm'
  ClientHeight = 135
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 18
    Width = 30
    Height = 13
    Caption = 'UObj :'
  end
  object Label2: TLabel
    Left = 9
    Top = 52
    Width = 36
    Height = 13
    Caption = 'UObj2 :'
  end
  inline frUObjCommon: TN_UObjFrame
    Left = 85
    Top = 13
    Width = 122
    Height = 23
    TabOrder = 0
    ExplicitLeft = 85
    ExplicitTop = 13
    ExplicitWidth = 122
  end
  inline frUObj2Common: TN_UObj2Frame
    Left = 87
    Top = 50
    Width = 135
    Height = 22
    PopupMenu = UObj2PopupMenu
    TabOrder = 1
    ExplicitLeft = 87
    ExplicitTop = 50
    ExplicitWidth = 135
    ExplicitHeight = 22
    inherited UObj2ActList: TActionList
      Images = N_ButtonsForm.ButtonsList
    end
  end
  object UObjPopupMenu: TPopupMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 50
    Top = 11
    object miExecuteComp: TMenuItem
      Action = frUObjCommon.aExecuteComp
    end
    object miViewAsMap1: TMenuItem
      Action = frUObjCommon.aViewMain
    end
    object miViewInfo1: TMenuItem
      Action = frUObjCommon.aViewInfo
    end
    object miViewFields1: TMenuItem
      Action = frUObjCommon.aViewFields
    end
    object EditFields1: TMenuItem
      Action = frUObjCommon.aEditFields
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miEditUObj: TMenuItem
      Action = frUObjCommon.aEditParams
    end
    object miEditDataSys: TMenuItem
      Action = frUObjCommon.aEditUDRArray
    end
    object miEditUDVector1: TMenuItem
      Action = frUObjCommon.aEditUDVector
    end
    object miSpecialEdit11: TMenuItem
      Action = frUObjCommon.aSpecialEdit1
    end
    object miSpecialEdit21: TMenuItem
      Action = frUObjCommon.aSpecialEdit2
    end
    object miSpecialEdit31: TMenuItem
      Action = frUObjCommon.aSpecialEdit3
    end
    object LoadSelffromMVFile1: TMenuItem
      Action = frUObjCommon.aUDMemLoad
    end
    object SaveSelfToMVFile1: TMenuItem
      Action = frUObjCommon.aUDMemSave
    end
    object ViewSelfAsHex1: TMenuItem
      Action = frUObjCommon.aUDMemViewAsText
    end
    object aArchSecLoad1: TMenuItem
      Action = frUObjCommon.aArchSecLoad
    end
    object aArchSecSave1: TMenuItem
      Action = frUObjCommon.aArchSecSave
    end
    object aArchSecEditParams1: TMenuItem
      Action = frUObjCommon.aArchSecEditParams
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object miEdRename1: TMenuItem
      Action = frUObjCommon.aEdRename
    end
    object miEdDelete1: TMenuItem
      Action = frUObjCommon.aEdDelete
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miUObjName: TMenuItem
      Checked = True
      Enabled = False
    end
  end
  object UObj2PopupMenu: TPopupMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 50
    Top = 49
    object miSelectUObj: TMenuItem
      Action = frUObj2Common.aSelectUObj
    end
    object miSetToSelected: TMenuItem
      Action = frUObj2Common.aSetToVtree
    end
    object miShowUObjMenu: TMenuItem
      Action = frUObj2Common.aShowUObjMenu
    end
  end
  object OpenDialog: TOpenDialog
    Left = 208
    Top = 8
  end
  object CommonActions: TActionList
    Left = 8
    Top = 88
    object aProtocolView: TAction
      Caption = 'View Protocol Window'
    end
  end
end
