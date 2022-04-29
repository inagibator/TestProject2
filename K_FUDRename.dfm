inherited K_FormUDRename: TK_FormUDRename
  Left = 517
  Top = 535
  Width = 342
  Height = 111
  Caption = ''
  Constraints.MaxHeight = 111
  Constraints.MinHeight = 111
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object LbAliase: TLabel [0]
    Left = 8
    Top = 13
    Width = 53
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object LbName: TLabel [1]
    Left = 47
    Top = 34
    Width = 14
    Height = 13
    Caption = 'ID:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 321
    Top = 65
    TabOrder = 4
  end
  object EdAliase: TEdit
    Left = 64
    Top = 8
    Width = 270
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'EdAliase'
  end
  object EdName: TEdit
    Left = 64
    Top = 32
    Width = 270
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'EdName'
  end
  object BtCancel: TButton
    Left = 218
    Top = 56
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 278
    Top = 56
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
end
