inherited K_FormCMSASelectProvider: TK_FormCMSASelectProvider
  Left = 20
  Top = 540
  Width = 420
  Height = 118
  BorderIcons = [biSystemMenu]
  Caption = 'Dentist '
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
    Action = aAddProvider
    Anchors = [akLeft, akBottom]
    TabOrder = 2
  end
  object BtModify: TButton
    Left = 84
    Top = 51
    Width = 65
    Height = 23
    Action = aModifyProvider
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object BtDelete: TButton
    Left = 156
    Top = 51
    Width = 65
    Height = 23
    Action = aDeleteProvider
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object CmBProviders: TComboBox
    Left = 11
    Top = 16
    Width = 387
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ItemHeight = 13
    TabOrder = 5
    OnChange = CmBProvidersChange
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
    object aAddProvider: TAction
      Caption = '&New'
      Hint = 'Add new dentist'
      OnExecute = aAddProviderExecute
    end
    object aModifyProvider: TAction
      Caption = '&Modify'
      Hint = 'Modify existing dentist'
      OnExecute = aModifyProviderExecute
    end
    object aDeleteProvider: TAction
      Caption = '&Delete'
      Hint = 'Delete existing dentist'
      OnExecute = aDeleteProviderExecute
    end
    object aRestoreProvider: TAction
      Caption = '&Restore'
      OnExecute = aRestoreProviderExecute
    end
    object aDeleteProviderForever: TAction
      Caption = '&Delete'
      Hint = 'Delete forever'
      OnExecute = aDeleteProviderForeverExecute
    end
  end
end
