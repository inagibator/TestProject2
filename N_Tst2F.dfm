object N_Test2Form: TN_Test2Form
  Left = 646
  Top = 304
  Width = 490
  Height = 570
  Caption = 'N_Test2Form'
  Color = clYellow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 321
    Width = 482
    Height = 8
    Cursor = crVSplit
    Align = alBottom
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 493
    Width = 482
    Height = 19
    Panels = <>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 482
    Height = 37
    ButtonHeight = 31
    ButtonWidth = 32
    Caption = 'ToolBar1'
    Color = 12615935
    Indent = 2
    ParentColor = False
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 2
      Top = 2
      Caption = 'ToolButton1'
      ImageIndex = 0
      OnClick = bnTest2Click
    end
    object ToolButton2: TToolButton
      Left = 34
      Top = 2
      Caption = 'ToolButton2'
      ImageIndex = 1
      OnClick = bnTest2Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 329
    Width = 482
    Height = 164
    Align = alBottom
    BevelWidth = 6
    Caption = 'Panel3'
    Color = clBackground
    TabOrder = 3
    DesignSize = (
      482
      164)
    object Panel4: TPanel
      Left = 24
      Top = 24
      Width = 345
      Height = 105
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Panel4'
      Color = clInfoBk
      TabOrder = 0
      object Panel5: TPanel
        Left = 16
        Top = 64
        Width = 49
        Height = 33
        Caption = 'Panel5'
        Color = clBlue
        TabOrder = 0
      end
    end
    object Button1: TButton
      Left = 400
      Top = 24
      Width = 65
      Height = 121
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Button1'
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 37
    Width = 482
    Height = 284
    Align = alClient
    BevelWidth = 3
    Caption = 'Panel1'
    Color = clActiveCaption
    TabOrder = 2
    DesignSize = (
      482
      284)
    object Panel2: TPanel
      Left = 16
      Top = 16
      Width = 458
      Height = 252
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelWidth = 4
      Caption = 'Panel2'
      Color = clFuchsia
      TabOrder = 0
    end
  end
  inline TranspFrame: TN_TranspFrame
    Left = 16
    Top = 96
    Width = 193
    Height = 169
    TabOrder = 4
    Visible = False
  end
  object MainMenu1: TMainMenu
    Left = 88
    Top = 8
    object Dummy11: TMenuItem
      Caption = 'Dummy1'
      object Dummy111: TMenuItem
        Caption = 'Dummy1_1'
      end
      object Dummy121: TMenuItem
        Caption = 'Dummy1_2'
      end
      object Print1: TMenuItem
        Action = N_CMResForm.aGoToPrint
      end
    end
    object Dummy21: TMenuItem
      Caption = 'Dummy2'
    end
  end
end
