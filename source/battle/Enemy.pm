#===================================================================
#        パーティ情報取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Enemy;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    $self->{CommonDatas}{NickEnemy} = {};
    $self->{NickEnemy} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "battle_no",
                "enemy_id",
                "suffix_id",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/enemy_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号,ターン別参加者一覧ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no = shift;
    my $nodes = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->GetEnemyData($nodes);
    
    return;
}

#-----------------------------------#
#    敵データ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetEnemyData{
    my $self  = shift;
    my $turn_table_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return;}

    my $party_order = 0;

    my $enemy_table = $$turn_table_nodes[1];

    if (!$enemy_table) { # バグによる開始時無抵抗敗北の結果に対応
        $enemy_table = $$turn_table_nodes[0];
    }

    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$enemy_table);

    foreach my $tr_node (@$tr_nodes) {
        my $td_nodes = &GetNode::GetNode_Tag("td", \$tr_node);

        if (scalar(@$td_nodes) < 2) { next; }

        my $b_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "C3", \$$td_nodes[1]);

        if (!scalar(@$b_nodes)) { next; }
        
        my $enemy_name = $$b_nodes[0]->as_text;
        my $suffix_id = 0;
        if ($enemy_name =~ s/([A-Z]+)$//) {
            $suffix_id = $self->{CommonDatas}{ProperName}->GetOrAddId($1);
        };

        my $enemy_id = $self->{CommonDatas}{ProperName}->GetOrAddId($enemy_name);

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{BattleNo}, $enemy_id, $suffix_id) ));

    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
