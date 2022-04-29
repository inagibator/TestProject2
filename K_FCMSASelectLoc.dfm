inherited K_FormCMSASelectLocation: TK_FormCMSASelectLocation
  Left = 70
  Top = 531
  Width = 420
  Height = 118
  BorderIcons = [biSystemMenu]
  Caption = 'Dental Practice'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 400
    Top = 72
  end
  object BtOK: TButton
    Left = 259
    Top = 51
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtAdd: TButton
    Left = 12
    Top = 51
    Width = 65
    Height = 23
    Action = aAddLocation
    Anchors = [akLeft, akBottom]
    TabOrder = 2
  end
  object BtModify: TButton
    Left = 84
    Top = 51
    Width = 65
    Height = 23
    Action = aModifyLocation
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object BtDelete: TButton
    Left = 156
    Top = 51
    Width = 65
    Height = 23
    Action = aDeleteLocation
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object CmBLocations: TComboBox
    Left = 12
    Top = 16
    Width = 389
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ItemHeight = 13
    TabOrder = 5
    OnChange = CmBLocationsChange
  end
  object BtCancel: TButton
    Left = 331
    Top = 51
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object ActionList1: TActionList
    Left = 232
    Top = 48
    object aAddLocation: TAction
      Caption = '&New'
      Hint = 'Add new practice'
      OnExecute = aAddLocationExecute
    end
    object aModifyLocation: TAction
      Caption = '&Modify'
      Hint = 'Modify existing practice'
      OnExecute = aModifyLocationExecute
    end
    object aDeleteLocation: TAction
      Caption = '&Delete'
      Hint = 'Delete existing practice'
      OnExecute = aDeleteLocationExecute
    end
    object aRestoreLocation: TAction
      Caption = '&Restore'
      OnExecute = aRestoreLocationExecute
    end
    object aDeleteLocationForever: TAction
      Caption = '&Delete'
      Hint = 'Delete forever'
      OnExecute = aDeleteLocationForeverExecute
    end
  end
end
