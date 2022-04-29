inherited K_FormCMCustToolbar: TK_FormCMCustToolbar
  Left = 283
  Top = 176
  BorderStyle = bsSingle
  Caption = 'Toolbar Customization'
  ClientHeight = 246
  ClientWidth = 419
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 407
    Top = 234
  end
  object PnToolbars: TPanel
    Left = 0
    Top = 0
    Width = 419
    Height = 201
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'Pn1'
    TabOrder = 1
    object PnBBToolbars: TPanel
      Left = 204
      Top = 0
      Width = 106
      Height = 201
      Align = alRight
      BevelOuter = bvNone
      Caption = 'PnBBToolbars'
      TabOrder = 0
      Visible = False
      object TBBB1: TToolBar
        Left = 0
        Top = 0
        Width = 54
        Height = 201
        Align = alLeft
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'TBBB1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 0
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
      object TBBB2: TToolBar
        Left = 54
        Top = 0
        Width = 53
        Height = 201
        Align = alLeft
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'TBBB2'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 1
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
    end
    inline VTreeFrame: TN_VTreeFrame
      Left = 0
      Top = 0
      Width = 204
      Height = 201
      Align = alClient
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 1
      OnEndDrag = VTreeFrameEndDrag
      inherited TreeView: TTreeView
        Width = 204
        Height = 201
      end
    end
    object PnSBToolbars: TPanel
      Left = 310
      Top = 0
      Width = 109
      Height = 201
      Align = alRight
      BevelOuter = bvNone
      Caption = 'PnBBToolbars'
      TabOrder = 2
      object TBSB1: TToolBar
        Left = 0
        Top = 0
        Width = 27
        Height = 201
        Align = alLeft
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSB1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 0
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
      object TBSB2: TToolBar
        Left = 27
        Top = 0
        Width = 26
        Height = 201
        Align = alLeft
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSB2'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 1
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
      object TBSB3: TToolBar
        Left = 53
        Top = 0
        Width = 26
        Height = 201
        Align = alLeft
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSB3'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 2
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
      object TBSB4: TToolBar
        Left = 79
        Top = 0
        Width = 26
        Height = 201
        Align = alLeft
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSB4'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        PopupMenu = TBPopupMenu
        TabOrder = 3
        Wrapable = False
        OnDragOver = ToolBarDragOver
        OnMouseDown = ToolBarMouseDown
      end
    end
  end
  object ChBSmallButtons: TCheckBox
    Left = 9
    Top = 216
    Width = 99
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Small Buttons'
    TabOrder = 2
    OnClick = ChBSmallButtonsClick
  end
  object BtOK: TButton
    Left = 275
    Top = 213
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 344
    Top = 213
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object BtDefaults: TButton
    Left = 144
    Top = 213
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Set defaults'
    TabOrder = 5
    OnClick = BtDefaultsClick
  end
  object DragTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = DragTimerTimer
    Left = 184
  end
  object TBPopupMenu: TPopupMenu
    OnPopup = TBPopupMenuPopup
    Left = 104
    Top = 208
    object Delete1: TMenuItem
      Caption = 'Delete button'
      OnClick = Delete1Click
    end
    object Addselectedbefore1: TMenuItem
      Caption = 'Insert selected actions before button'
      OnClick = Addselectedbefore1Click
    end
    object Addselectedafter1: TMenuItem
      Caption = 'Add selected actions to toolbar'
      OnClick = Addselectedafter1Click
    end
  end
end
