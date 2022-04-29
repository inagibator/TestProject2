inherited K_FormCMProfileTwain: TK_FormCMProfileTwain
  Left = 139
  Top = 215
  Caption = 'X-Ray / TWAIN  Profile'
  ClientHeight = 284
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Top = 274
  end
  inherited BtCancel: TButton
    Top = 252
  end
  inherited BtOK: TButton
    Left = 211
    Top = 252
  end
  inherited BtAuto: TButton
    Top = 218
    Width = 108
  end
  inherited BtSet: TButton
    Left = 130
    Top = 218
    Width = 108
    Caption = 'General Settings ...'
  end
  object bnSpecial: TButton
    Left = 245
    Top = 217
    Width = 113
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Advanced Settings  ...'
    TabOrder = 9
    OnClick = bnSpecialClick
  end
end
