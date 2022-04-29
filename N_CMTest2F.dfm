inherited N_CMTest2Form: TN_CMTest2Form
  Left = 431
  Top = 330
  BorderStyle = bsToolWindow
  Caption = 'N_CMTest2Form'
  ClientHeight = 354
  ClientWidth = 407
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  OnHide = FormHide
  OnKeyDown = MyKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 397
    Top = 344
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 335
    Width = 407
    Height = 19
    Panels = <>
  end
  object bnCreateNewSlide: TButton
    Left = 48
    Top = 24
    Width = 193
    Height = 25
    Caption = 'Create new Slide from Image File'
    TabOrder = 2
    OnClick = bnCreateNewSlideClick
  end
  object bnChangeAndShow: TButton
    Left = 48
    Top = 94
    Width = 193
    Height = 25
    Caption = 'Change Image and Show '
    TabOrder = 3
    OnClick = bnChangeAndShowClick
  end
  object bnSaveImage: TButton
    Left = 48
    Top = 129
    Width = 193
    Height = 25
    Caption = 'Save Image'
    TabOrder = 4
    OnClick = bnSaveImageClick
  end
  object bnStartChanging: TButton
    Left = 48
    Top = 59
    Width = 193
    Height = 25
    Caption = 'Start Changing Image'
    TabOrder = 5
    OnClick = bnStartChangingClick
  end
  object bnTest1: TButton
    Left = 48
    Top = 165
    Width = 193
    Height = 25
    Caption = 'Test1'
    TabOrder = 6
    OnClick = bnTest1Click
  end
  object bnSetShortCut: TButton
    Left = 11
    Top = 198
    Width = 75
    Height = 25
    Caption = 'Set ShortCut'
    TabOrder = 7
    OnClick = bnSetShortCutClick
  end
  object edShortCut: TEdit
    Left = 94
    Top = 199
    Width = 174
    Height = 21
    Enabled = False
    TabOrder = 8
    Text = 'None'
  end
  inline frFName: TN_FileNameFrame
    Tag = 161
    Left = 7
    Top = 224
    Width = 394
    Height = 32
    PopupMenu = frFName.FilePopupMenu
    TabOrder = 9
    inherited Label1: TLabel
      Left = 3
      Width = 22
      Caption = 'File :'
    end
    inherited mbFileName: TComboBox
      Left = 30
      Width = 336
      OnChange = nil
    end
    inherited bnBrowse_1: TButton
      Left = 369
      Width = 22
    end
  end
  object bnConvertFiles: TButton
    Left = 48
    Top = 257
    Width = 193
    Height = 25
    Caption = 'Convert Files to Unicode'
    TabOrder = 10
    OnClick = bnConvertFiles1Click
  end
  object Button1: TButton
    Left = 48
    Top = 297
    Width = 193
    Height = 25
    Caption = 'Convert Files to Utf8'
    TabOrder = 11
    OnClick = bnConvertFiles2Click
  end
end
