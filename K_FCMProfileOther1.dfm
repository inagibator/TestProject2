inherited K_FormCMProfileOther1: TK_FormCMProfileOther1
  Left = 105
  Top = 402
  Caption = 'X-Ray / Other Device Profile'
  ClientHeight = 284
  ClientWidth = 366
  DesignSize = (
    366
    284)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 356
    Top = 274
    ExplicitLeft = 356
    ExplicitTop = 274
  end
  inherited EdProfileName: TEdit
    Width = 246
    ExplicitWidth = 246
  end
  inherited CmBDevices: TComboBox
    Width = 246
    DropDownCount = 25
    ExplicitWidth = 246
  end
  inherited GBIconShortCut: TGroupBox
    Width = 336
    ExplicitWidth = 336
  end
  inherited BtCancel: TButton
    Left = 289
    Top = 252
    ExplicitLeft = 289
    ExplicitTop = 252
  end
  inherited BtOK: TButton
    Left = 209
    Top = 252
    ExplicitLeft = 209
    ExplicitTop = 252
  end
  inherited BtAuto: TButton
    Top = 217
    Width = 108
    ExplicitTop = 217
    ExplicitWidth = 108
  end
  inherited BtSet: TButton
    Left = 133
    Top = 217
    Width = 108
    Caption = 'General Settings ...'
    ExplicitLeft = 133
    ExplicitTop = 217
    ExplicitWidth = 108
  end
  inherited CmBMediaTypes: TComboBox
    Width = 246
    TabOrder = 9
    ExplicitWidth = 246
  end
  object bnSpecial: TButton
    Left = 251
    Top = 217
    Width = 107
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Device Settings ...'
    TabOrder = 8
    OnClick = bnSpecialClick
  end
  object PnWait: TPanel
    Left = 12
    Top = 251
    Width = 190
    Height = 24
    BevelOuter = bvNone
    TabOrder = 10
  end
end
