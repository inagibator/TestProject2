inherited K_FormCMImportReverse: TK_FormCMImportReverse
  Left = 463
  Top = 341
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Undo last import after conversion'
  ClientHeight = 128
  ClientWidth = 312
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 16
    Top = 13
    Width = 283
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    Shape = bsFrame
  end
  object Bevel3: TBevel [1]
    Left = 16
    Top = 38
    Width = 283
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    Shape = bsFrame
  end
  object Bevel2: TBevel [2]
    Left = 16
    Top = 63
    Width = 283
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    Shape = bsFrame
  end
  object Label2: TLabel [3]
    Left = 24
    Top = 19
    Width = 75
    Height = 13
    Caption = 'Last import date'
  end
  object LbIDate: TLabel [4]
    Left = 188
    Top = 19
    Width = 96
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = '00'
  end
  object Label5: TLabel [5]
    Left = 24
    Top = 43
    Width = 73
    Height = 13
    Caption = 'Last import time'
  end
  object LbITime: TLabel [6]
    Left = 180
    Top = 43
    Width = 104
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = '00'
  end
  object Label3: TLabel [7]
    Left = 24
    Top = 68
    Width = 78
    Height = 13
    Caption = 'Imported objects'
  end
  object LbICount: TLabel [8]
    Left = 188
    Top = 68
    Width = 96
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = '00'
  end
  object LbRemovedCount: TLabel [9]
    Left = 18
    Top = 104
    Width = 135
    Height = 13
    AutoSize = False
    Caption = ' 1111 deleted objects'
  end
  inherited BFMinBRPanel: TPanel
    Left = 302
    Top = 118
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 233
    Top = 97
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 164
    Top = 97
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
end
