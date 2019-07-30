clc
clear

px = 30; %ÿ�����ڵ�Ԫ�ĳ���
py = 30;
% total = zeros(px, py, 512);
% matrix = matrix_generate(px, py);
% a = 1;
% while a <= 512
%     for b = 1: 512
%         if matrix == total(:, :, b)
%             matrix = matrix_generate(px, py);
%             break
%         else
%             total(:, :, a) = matrix;
%         end
%     end
%     a = a + 1;
%     matrix = matrix_generate(px, py);
% end
% for i = 1: 512
%     temp_matrix = total(:, :, i);
%     mfilename = ['C:\Users\Antlab\Desktop\hjj\m\', num2str(i), '-m.txt'];
%     save(mfilename, 'temp_matrix', '-ascii');
% end

for epoch = 4402: 10000

tmp_path = ['I:\git_j\torch\data\meta\', num2str(epoch), '-data.txt'];
temp_matrix = load(tmp_path);
% temp_matrix = [0, 0, 1;
%     0, 1, 1;
%     0, 0, 0];

a=0.15;   %�ϲ���Ƭ�ĳ�
b=0.15;   %�ϲ���Ƭ�Ŀ�
t=0.6;   %���ʻ���ĺ�ȣ�
Frq=[2, 10]; %����Ƶ����Ƶ��

%% CST�ļ���ʼ��
cst = actxserver('CSTStudio.application');%��������CSTӦ�ÿؼ�
mws = invoke(cst, 'NewMWS');%�½�һ��MWS��Ŀ
app = invoke(mws, 'GetApplicationName');%��ȡ��ǰӦ������
ver = invoke(mws, 'GetApplicationVersion');%��ȡ��ǰӦ�ð汾��
invoke(mws, 'FileNew');%�½�һ��CST�ļ�
path=pwd;%��ȡ��ǰm�ļ���·��
filename='\metamaterialabsorber-1.cst';%�½���CST�ļ�����
% filename = ['\', num2str(epoch), '.cst'];
fullname=[path filename];
invoke(mws, 'SaveAs', fullname, 'True');%True��ʾ���浽ĿǰΪֹ�Ľ��
invoke(mws, 'DeleteResults');%ɾ��֮ǰ�Ľ����ע�����н����������޸�ģ�ͻ���ֵ�����ʾ�Ƿ�ɾ��������������еĳ����ֹͣ����ȴ��ֶ��������ʹ֮��ʧ
%%CST�ļ���ʼ������

%ȫ�ֵ�λ��ʼ��
units = invoke(mws, 'Units');
invoke(units, 'Geometry', 'mm');
invoke(units, 'Frequency', 'ghz');
invoke(units, 'Time', 'ns');
invoke(units, 'TemperatureUnit', 'kelvin');
release(units);
%%ȫ�ֵ�λ��ʼ������

%%����Ƶ������
solver = invoke(mws, 'Solver');
invoke(solver, 'FrequencyRange', Frq(1), Frq(2));
release(solver);



%������������
background=invoke(mws,'Background');
invoke(background,'Resetbackground');
invoke(background,'Type','Normal');
release(background);

floquetport=invoke(mws,'FloquetPort');
invoke(floquetport,'Reset');
invoke(floquetport,'SetDialogTheta','0');
invoke(floquetport,'SetDialogPhi','0');
invoke(floquetport,'SetSortcode','+beta/pw');
invoke(floquetport,'SetCustomizedListFlag','False');
invoke(floquetport,'Port','Zmin');
invoke(floquetport,'SetNumberOfModesConsidered','2');
invoke(floquetport,'Port','Zmax');
invoke(floquetport,'SetNumberOfModesConsidered','2');
release(floquetport);

boundary=invoke(mws,'Boundary');
invoke(boundary, 'Xmin','unit cell');
invoke(boundary, 'Xmax', 'unit cell');
invoke(boundary, 'Ymin', 'unit cell');
invoke(boundary, 'Ymax', 'unit cell');
invoke(boundary, 'Zmin', 'expanded open');
invoke(boundary, 'Zmax', 'expanded open');
invoke(boundary, 'Xsymmetry', 'none');
invoke(boundary, 'Ysymmetry', 'none');
invoke(boundary, 'Zsymmetry', 'none');
invoke(boundary, 'XPeriodicShift', '0.0');
invoke(boundary, 'YPeriodicShift', '0.0');
invoke(boundary, 'ZPeriodicShift', '0.0');
    
invoke(boundary, 'SetPeriodicBoundaryAnglesDirection', 'inward');
invoke(boundary,  'UnitCellFitToBoundingBox', 'True');
invoke(boundary,  'UnitCellDs1', '0.0');
invoke(boundary,  'UnitCellDs2',"0.0");
invoke(boundary,  'UnitCellAngle', '90.0');
release(boundary);

meshsettings=invoke(mws,'MeshSettings');
invoke(meshsettings,'SetMeshType','Tet');
invoke(meshsettings,'Set','version','1%');
release(meshsettings);

mesh=invoke(mws,'Mesh');
invoke(mesh,'MeshType','Tetrahedral');
release(mesh);

%%�½�������ʲ���
material = invoke(mws, 'Material');
material1 = 'material265';
er1 = 4.4;
invoke(material, 'Reset');
invoke(material, 'Name', material1);
invoke(material, 'FrqType', 'all');
invoke(material, 'Type', 'Normal');
invoke(material, 'Epsilon', er1);
invoke(material, 'Create');
release(material);

%%��ģ��
brick=invoke(mws,'Brick');
Str_Name='substate';
Str_Component='sub';
Str_Material=material1;
x=[0,px];
y=[0,py];
z=[-t,0]; 
invoke(brick, 'Reset');
invoke(brick, 'Name', Str_Name);
invoke(brick, 'Component', Str_Component);
invoke(brick, 'Material', Str_Material);
invoke(brick, 'Xrange', x(1), x(2));
invoke(brick, 'Yrange', y(1), y(2));
invoke(brick, 'Zrange', z(1), z(2));
invoke(brick, 'Create');

%�ϲ����Ƭ
for yy = 1: py
    for xx = 1: px
        if temp_matrix(xx, yy) == double(1)
            Str_Name = num2str((yy - 1) * px + xx);
            Str_Component='toplayer';
            Str_Material='PEC';
            x=[xx - 1, xx];
            y=[yy - 1, yy];
            z=[0,0];
            invoke(brick, 'Reset');
            invoke(brick, 'Name', Str_Name);
            invoke(brick, 'Component', Str_Component);
            invoke(brick, 'Material', Str_Material);
            invoke(brick, 'Xrange', x(1), x(2));
            invoke(brick, 'Yrange', y(1), y(2));
            invoke(brick, 'Zrange', z(1), z(2));
            invoke(brick, 'Create');
        end
    end
end

fdsolver=invoke(mws,'FDsolver');
invoke(fdsolver,'Reset');
invoke(fdsolver,'Stimulation','List','List');
invoke(fdsolver,'ResetExcitationList');
invoke(fdsolver,'AddtoExcitationList','Zmax','TE(0,0);TM(0,0)');
invoke(fdsolver,'LowFrequencyStabilization','False');
invoke(fdsolver,'SetNumberOfResultDataSamples','49'); 

invoke(fdsolver, 'Start');

release(fdsolver);

Res=invoke(mws,'ResultTree'); 
number=invoke(Res,'GetResultIDsFromTreeItem','1D Results\S-Parameters\SZmax(1),Zmax(1)'); 
N=numel(number);
A_Freq=zeros(49,1); 
A_Complex=zeros(49,2); 
c=invoke(Res,'GetResultFromTreeItem','1D Results\S-Parameters\SZmax(1),Zmax(1)',number{1}); 
A_Freq(:,1)=invoke(c,'GetArray','x'); 
c=invoke(Res,'GetResultFromTreeItem','1D Results\S-Parameters\SZmax(1),Zmax(1)',number{1}); 
A_Complex(:,1)=invoke(c,'GetArray','yre'); 
A_Complex(:,2)=invoke(c,'GetArray','yim'); 
A=[A_Freq,A_Complex]; 

number2=invoke(Res,'GetResultIDsFromTreeItem','1D Results\S-Parameters\SZmax(2),Zmax(1)');
N=numel(number2);
B_Freq=zeros(49,1); 
B_Complex=zeros(49,2); 
c2=invoke(Res,'GetResultFromTreeItem','1D Results\S-Parameters\SZmax(2),Zmax(1)',number{1}); 
B_Freq(:,1)=invoke(c2,'GetArray','x'); 
c2=invoke(Res,'GetResultFromTreeItem','1D Results\S-Parameters\SZmax(2),Zmax(1)',number{1}); 
B_Complex(:,1)=invoke(c2,'GetArray','yre'); 
B_Complex(:,2)=invoke(c2,'GetArray','yim'); 
B=[B_Freq,B_Complex]; 

invoke(mws,'Save');

invoke(mws,'Quit'); 
 
release(mws); 
release(cst);
sfilename = ['C:\Users\Antlab\Desktop\hjj\s11\', num2str(epoch), '-s11.txt'];
mfilename = ['C:\Users\Antlab\Desktop\hjj\m\', num2str(epoch), '-m.txt'];
sfilename2 = ['C:\Users\Antlab\Desktop\hjj\s21\', num2str(epoch), '-s21.txt'];
save(sfilename, 'A', '-ascii');
save(sfilename2, 'B', '-ascii');
save(mfilename, 'temp_matrix', '-ascii');
disp('-------------------------------------------')
disp(epoch)
pause(2)
end
% plot(A(:, 1), 20 * log10(abs(A(:, 2) + 1i * A(:, 3))));