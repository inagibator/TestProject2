inherited K_FormCMSlideIcon: TK_FormCMSlideIcon
  Left = 546
  Top = 287
  BorderStyle = bsSingle
  Caption = 'Objects deletion confirmation'
  ClientHeight = 280
  ClientWidth = 520
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage [0]
    Left = 371
    Top = 14
    Width = 32
    Height = 32
  end
  object LbHead: TLabel [1]
    Left = 279
    Top = 70
    Width = 232
    Height = 91
    Alignment = taCenter
    AutoSize = False
    Caption = 
      '_Do you confirm that you really want to delete the selected obje' +
      'ct?'
    WordWrap = True
  end
  object SlideImage: TImage [2]
    Left = 16
    Top = 16
    Width = 250
    Height = 250
  end
  inherited BFMinBRPanel: TPanel
    Left = 510
    Top = 270
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 340
    Top = 243
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Yes'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 428
    Top = 243
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'No'
    ModalResult = 2
    TabOrder = 1
  end
end
