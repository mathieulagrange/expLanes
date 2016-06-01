
function LatexObj_s = LatexCreator(varargin)
%%
%
%
% function LatexObj_s = LatexCreator2(TEX_file_name)
%
% Create a LatexCreator object
%
%
%
%   INPUTS:
%
%   - TEX_file_name     : Latexfile    (defaul=./LatexCreator/LatexCreator.tex)
%
%
%
%   OUTPUT:
%
%       LatexObj_s      : LatexCreator object.
%
%
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
%
%  METHODS:
%
%  -----------------------------------------------
%  LatexCreator::addSection('SECTION_NAME')
%
%       adds an new section.
%
%
%  -----------------------------------------------
%  LatexCreator::newPage()
%
%       adds an new page.
%
%
%  -----------------------------------------------
%  LatexCreator::addText('TEXT')
%
%       adds some text.
%
%
%
%  -----------------------------------------------
%   LatexCreator::addFigure()
%
%       adds the current figure.
%
%
%   LatexCreator::addFigure('Property1',PropertyValue1,'Property2',PropertyValue2,...).
%
%
%       sets the values of the specified properties of the latex figure.
%       available properties are:
%
%         PROPERTY    PROPERTYVALUE EXEMPLE       DESCRIPTION
%         'width'          '70mm'              width of the figure
%         'height'          '5cm'              height of the figure
%         'caption'    'this is a caption'     caption of the figure
%
%
%  -----------------------------------------------
%   LatexCreator::addTable(M) adds a table from the M matrix.
%
%         M must be a double matrix with less of 8 colons.
%
%   LatexCreator::addTable(M,'Property1',PropertyValue1,'Property2',PropertyValue2,...).
%
%
%       sets the values of the specified properties of the latex table.
%       available properties are:
%
%         PROPERTY        PROPERTYVALUE EXEMPLE          DESCRIPTION
%         'legend'   {'col1 legend','col2 legend'}      colon legends
%         'caption'    'this is a caption'           caption of the table
%
%
%  -----------------------------------------------


if(nargin==0)
    warning('arg error')
    disp('USAGE: Obj=LatexCreator(tex_file_name)');
    LatexObj_s=[];
    return
    
end

Data = struct('Dir', {'./'},'tex',{[]},'author' ,{' '}, 'title' ,{' '},'TexFn',{''},'figure_number',{0});

CONFIG=[];


LatexObj_s = struct('disp',@disp_, ...
    'edit',@edit_, ...
    'createPDF',@createPDF,...
    'addFigure',@addFigure,...
    'addSection',@addSection,...
    'addText',@addText,...
    'addInput',@addInput,...
    'addTable',@addTable,...
    'addTextFile',@addTextFile,...
    'newPage',@newPage,...
    'addLine',@addLine,...
    'set_CONFIG',@set_CONFIG,...
    'get_CONFIG',@get_CONFIG,...
    'deleteLastFig',@deleteLastFig,...
    'set_CONFIG_from_file',@set_CONFIG_from_file,...
    'addSubFigure',@addSubFigure,...
    'viewPDF',@viewPDF,...
    'get',@get_);

% 'addSubFigure',@addSubFigure,...



CONSTRUCTOR(varargin{:});


%% Constructeur






    function CONSTRUCTOR(tex_file, keep, author_name, title, projectName, template, noFigDir, slides, noFlag)
        
        Data.TexFn=tex_file;
        if nargin>2, Data.author=strrep(author_name, '_', '\_'); end
        if nargin>3, Data.title=strrep(title, '_', '\_'); end
        if nargin<6, template=1; end
        if nargin<7, noFigDir=0; end
        if nargin<8, slides=0; end
         if nargin<9, Data.noFlag=0; else Data.noFlag=noFlag; end
        
        % extraction nom repertoire et nom de fichier
        TmpCell=strread(Data.TexFn,'%s','delimiter','/');
        LengthStr=length(TmpCell);
        
        Data.projectName = strrep(projectName, '_', '\_');
        Data.style = slides;
        if LengthStr == 0, disp('LatexCreator() Error : Bad file name argument'); return ; end
        
        if LengthStr == 1,
            Data.Dir='./';
            Data.TexFn = TmpCell{1};
        end
        
        if  LengthStr > 1
            
            if TmpCell{1} == '~'
                
                Data.Dir=getenv('HOME');
            else
                Data.Dir=TmpCell{1};
            end
            
            for pos=2:length(TmpCell)-1
                Data.Dir=[Data.Dir '/' TmpCell{pos}];
            end
            
        end
        Data.Dir=[Data.Dir '/'];
        
        
        
        Data.TexFn=TmpCell{end};
        Data.FullTexFn=[Data.Dir '/' Data.TexFn ];
        Data.keep = keep;
        
        
        if ( ~exist(Data.Dir,'dir')); mkdir(Data.Dir); end
        if ( ~noFigDir && ~exist([Data.Dir '/figures'],'dir'))
            mkdir([Data.Dir '/figures']);
        end
        if ( ~Data.keep || ~exist(Data.FullTexFn,'file')), createTemplate(template); end
        if ~noFigDir && Data.keep~=2 %&& exist([fileparts(tex_file) '/exposeTmp.tex'], 'file')
            fid = fopen([fileparts(tex_file) '/exposeTmp.tex'], 'w');
            fclose(fid);
        end
        if ~noFigDir
            if~exist([fileparts(tex_file) '/tex'], 'dir')
                mkdir([fileparts(tex_file) '/tex']);
            end
            if  exist([fileparts(tex_file) '/exposeTmp.tex'], 'file')
                copyfile([fileparts(tex_file) '/exposeTmp.tex'], [fileparts(tex_file) '/tex/exposeTmp.tex']);
            else
%                 fid = fopen([fileparts(tex_file) '/tex/exposeTmp.tex'], 'w');
%                 fclose(fid);
            end
        end
        set_Default_CONFIG();
        set_CONFIG_from_file();
        
        %         disp('---------------------- LatexCreator ----------------------')
        %         disp(['Opening ',Data.FullTexFn]);
        %         disp('----------------------------------------------------------')
        %
    end




%% METHODS

    function set_Default_CONFIG()
        % tous les elements de la config sont des string !
        CONFIG=struct('editor','matlab',...
            'viewer','kpdf',...
            'matPrecision','3');
        
    end

    function                                set_CONFIG(varargin)
        
        
        if (nargin==1 && isstruct(varargin{1}))
            CONFIG=varargin{1};
            return;
        end
        
        if (nargin==2)
            
            CONFIG=setfield(CONFIG,varargin{1},varargin{2});
            return;
        end
        
        
        error('Arg error');
        
    end

    function cfg=                           get_CONFIG(varargin)
        
        if(nargin == 0)
            cfg=CONFIG;
            return
        end
        
        if(nargin == 1)
            if (ischar(varargin{1}))
                cfg=getfield(CONFIG,varargin{1});
                return
            else
                error('Arg error')
            end
        end
        
        error('Arg error')
        
    end

    function set_CONFIG_from_file(varargin)
        
        tmp_cfg=get_LatexCreatorConfig('');
        
        key = fieldnames(tmp_cfg);
        value=struct2cell(tmp_cfg);
        
        for i=1:length(key)
            
            CONFIG=setfield(CONFIG,key{i},value{i});
            
        end
        
        
    end

    function edit_()
        
        
        
        if(strcmp(CONFIG.editor,'matlab'))
            
            edit(Data.FullTexFn);
            
        else
            cmd=[CONFIG.editor,' "',Data.FullTexFn,'" &'];
            
            [res,msg]=unix(cmd);
            if(res)
                disp(msg);
            end
        end
        
        
    end

    function disp_()
        
        disp('-----------------------')
        
        if (~exist('Data'))
            disp('Object LatexCreator vide');
        else
            disp('LatexCreator object')
            disp(Data);
            
            
        end
        
        
    end

    function D_s=get_()
        D_s=Data;
    end

    function viewPDF()
        
        if(~isfield(CONFIG,'viewer'))
            warning('no viewer defined')
            return
        end
        
        
        
        cmd=[CONFIG.viewer,' "',Data.FullTexFn(1:end-4),'.pdf" &'];
        unix(cmd);
        
    end

    function status=writeLatexFile()
        
        
        
        % Chargement fichier et recherche du flag
        
        
        %         copyfile(Data.FullTexFn,[Data.FullTexFn '~']);
        
        TEX=textread(Data.FullTexFn,'%s','delimiter','\n');
        
        for pos=1:length(TEX),
            if ~isempty(strfind(TEX{pos}, '\lstinputlisting')) && isempty(strfind(TEX{pos}, '../..')) && isempty(strfind(TEX{pos}, '..\..'))
                TEX{pos} = strrep(TEX{pos}, '{../', '{../../');
                TEX{pos} = strrep(TEX{pos}, '{..\', '{..\..\');
            end
        end
        
        
        FIND_FLAG_c=strfind(TEX,'expLanesInsertionFlag');
        flag_test=0;
        
        for pos_flag=1:length(FIND_FLAG_c)
            
            if(~isempty(FIND_FLAG_c{pos_flag})),flag_test=1;break,end
            
        end
        
        
        % Cas d'absence du flag
        if ( flag_test == 0 ),
            
            FIND_FLAG_c=strfind(TEX,'\end{document}');
            
            for pos_flag=1:length(FIND_FLAG_c)
                
                if(~isempty(FIND_FLAG_c{pos_flag})),flag_test=1;break,end
                
            end
            
            TEX{pos_flag+1}='\end{document}';
            
        end
        
        
        
        if ( flag_test == 0 ),disp('LatexCreator/writeLatexFile() Error : Bad Latex format, missing \end{document}');return; end
        
        [fid,res]=fopen(Data.FullTexFn,'wt');
        if Data.keep~=2 && exist([fileparts(Data.FullTexFn) 'exposeTmp.tex'], 'file')
            [fidTmp,res]=fopen([fileparts(Data.FullTexFn) 'exposeTmp.tex'],'at');
        else
            fidTmp = [];
        end
        
        % Ecriture premiere partie
        
        for no_line=1:pos_flag-1
            fprintf(fid,'%s \n',TEX{no_line});
            
        end
        
        
        % Ecriture Data.tex --------------------------------------
        for no_line=1:length(Data.tex)
            
            fprintf(fid,'%s \n',Data.tex{no_line});
            if ~isempty(fidTmp)
                fprintf(fidTmp,'%s \n',Data.tex{no_line});
            end
            
        end %-----------------------------------------------------
        
        % Ecriture Flag ------------------------------------------
        if ~Data.noFlag
        fprintf(fid,'%s \n','\input{tex/exposeTmp} % expLanesInsertionFlag DO NOT CLEAR (but move it where you want the generated temporary LaTEX code to be inserted)');
        end
        %---------------------------------------------------------
        
        % Ecriture seconde partie --------------------------------
        for no_line=pos_flag+1: length(TEX)
            
            fprintf(fid,'%s \n',TEX{no_line});
        end %-----------------------------------------------------
        
        
        
        
        fclose(fid);
        if ~isempty(fidTmp)
            fclose(fidTmp);
        end
        
        status=1;
    end

    function res = createPDF(silent)
        
        if nargin<1, silent=1; end
        
        %%-----------------------------------------------------------------
        %% COMPILATION
        
        if silent,
            if ispc
                silentString = '> NUL';
            else
                silentString = '>/dev/null 2>/dev/null';
            end
        else
            silentString =   '';
        end
        
        res=system(['bibtex "',Data.TexFn(1:end-4),'" ' silentString]); % 'cd "',Data.Dir,'";
        res=system(['pdflatex "',Data.TexFn,'" ' silentString ]); % cd "',Data.Dir,'";
        
        
        
        %         if (res==0)
        %             res=unix(['cd "',Data.Dir,'"; dvipdf "',Data.TexFn(1:end-4),'" ' ]);
        %         end
        
        
        
        if ( res == 0 )
            %             disp(' ')
            %             disp('----------------------------------')
            %             disp(['File succefully created on : ' Data.Dir '/' Data.TexFn(1:end-4) '.pdf']);
            %             disp('----------------------------------')
            %             disp(' ')
            %     viewPDF();
            
        else
            
            disp(' ')
            disp('----------------------------------')
            disp(['Error the file : ' Data.Dir '/' Data.TexFn(1:end-4) '.pdf was not created'])
            disp('----------------------------------')
            disp(' ')
            
        end
        
        
    end


    function status=createTemplate(style)
        ho=getenv('HOME');
        TemFn=[ho,'/.LatexToolBar/DefaultTemplate.tex'];
        
        
        
        if(~exist(TemFn,'file'))
            Data.tex=[];
            if style
                
                Data.tex{1}=' ';
                switch(Data.style)
                    case 'beamer'
                        Data.tex{end+1}='\documentclass{beamer}';
                        Data.tex{end+1}=' \usepackage{beamerthemedefault, multimedia}';
                        
                        Data.tex{end+1}=' \useoutertheme{smoothbars}';
                        Data.tex{end+1}=' \useinnertheme[shadow=true]{rounded}';
                        Data.tex{end+1}=' \setbeamercovered{transparent}';
                        Data.tex{end+1}=' \setbeamertemplate{navigation symbols}{}';
                        Data.tex{end+1}=' \setbeamertemplate{footline}[frame number]';
                    otherwise
                        Data.tex{end+1}= ['\documentclass[12pt,a4paper,fleqn]{' Data.style '}'];
                end
                %           Data.tex{end+1}='\usepackage[latin1]{inputenc}';
                %           Data.tex{end+1}='\usepackage[french]{babel}';
                Data.tex{end+1}='\usepackage{graphicx}';
                Data.tex{end+1}='\usepackage{morefloats}';
                %   Data.tex{end+1}='\usepackage[colorlinks=true,urlcolor=blue,citecolor=blue]{hyperref} ';
                Data.tex{end+1}='\usepackage{amsmath}';
                Data.tex{end+1}='\usepackage{amssymb}';
                %      Data.tex{end+1}='\usepackage[margin=0.5in]{geometry} % wide margin (remove if needed)';
                Data.tex{end+1}='\usepackage{rotating}';
                Data.tex{end+1}='% mcode options for matlab code insertion bw (for printing), numbered (line numbers), framed (frame around code blocks), useliterate (convert Matlab expressions to Latex ones), autolinebreaks (automatic code wraping, use it with caution';
                Data.tex{end+1}='\usepackage[literate]{mcode}';
                
                Data.tex{end+1}='\graphicspath{{figures/}{tex/}{../figures/}{../../}{../}} ';
                Data.tex{end+1}=['\title{' Data.title '}'];
                Data.tex{end+1}=['\author{ ' Data.author ' }'];
                Data.tex{end+1}=' ';
                Data.tex{end+1}='\begin{document}';
                Data.tex{end+1}=' ';
                Data.tex{end+1}='\maketitle';
                Data.tex{end+1}=' ';
                Data.tex{end+1}= '% Please use this file to document your experiment';
                Data.tex{end+1}= '% You can compile the report by setting the option ''report'' as detailed in your expLanes configuration file.';
                Data.tex{end+1}=' ';
                if strcmp(Data.style, 'beamer')
                    Data.tex{end+1}= ['This is the report to document the expLanes project ' Data.projectName ' using \LaTeX.'];
                end
                Data.tex{end+1}=' ';
                Data.tex{end+1}='\input{tex/exposeTmp} % expLanesInsertionFlag DO NOT CLEAR (but move it where you want the generated temporary LaTEX code to be inserted)';
                Data.tex{end+1}=' ';
                Data.tex{end+1}=' ';
                Data.tex{end+1}='\bibliographystyle{abbrvnat}';
                Data.tex{end+1}='\bibliography{bib}';
                Data.tex{end+1}=' ';
                Data.tex{end+1}='\end{document}';
                
            else
                Data.tex{end+1}='\input{tex/exposeTmp} % expLanesInsertionFlag DO NOT CLEAR (but move it where you want the generated temporary LaTEX code to be inserted)';
            end
            
            
            
            [fid,res]=fopen(Data.FullTexFn,'wt');
            
            if (~isempty(res)) % si erreur de creation
                disp(['LatexCreator/createTemplate : Erreur creation du fichier ' Data.TexFn]);
                disp(res)
                status=-1;
                return
            end
            
            % Ecriture
            
            for no_line=1:length(Data.tex)
                
                fprintf(fid,'%s \n',Data.tex{no_line});
                
            end
            
            
            fclose(fid);
        else
            
            copyfile(TemFn,Data.FullTexFn);
            
        end
        
    end

    function addSection(str)
        Data.tex=[];
        Data.tex{end+1}=['\section{' str '}'];
        writeLatexFile();
    end

    function addText(str)
        Data.tex=[];
        Data.tex{end+1}=str ;
        writeLatexFile();
    end

    function addFigure(varargin)
        
        
        h=gcf;
        
        if(nargin>=1)
            if(ishandle(varargin{1}))
                h=varargin{1};
            end
        end
        
        
        
        width='\textwidth';
        %             height='70mm';
        caption=[];
        
        if nargin>=2
            idx=find(strcmp( 'height',varargin)); if ( ~isempty( idx )), height = varargin{idx+1};  end;
            idx=find(strcmp( 'width' ,varargin)); if ( ~isempty( idx )),  width  = varargin{idx+1}; end;
            idx=find(strcmp( 'caption' ,varargin)); if ( ~isempty( idx )),  caption  = varargin{idx+1}; end;
            idx=find(strcmp( 'label' ,varargin)); if ( ~isempty( idx )),  label  = varargin{idx+1}; end;
        end
        
        
        
        Data.figure_number=1;
        
        while(exist([ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ],'file'))
            Data.figure_number=Data.figure_number+1;
        end
        
        
        LocalFig2eps(h,[ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ]);
        
        Data.tex=[];
        Data.tex{end+1}=' ';
        
        % sldie header
        if  strcmp(Data.style, 'beamer')
            Data.tex{end+1}=['\begin{frame}\frametitle{\small ' caption '}'];
        end
        
        
        Data.tex{end+1}='\begin{center}';
        Data.tex{end+1}='\begin{figure}';
        Data.tex{end+1}='\centering';
        Data.tex{end+1}=['\includegraphics[width=\textwidth,height=0.8\textheight,keepaspectratio]{./figures/Fig' num2str(Data.figure_number) '.pdf}']; % \width = width
        if ~ strcmp(Data.style, 'beamer')
            if (~isempty(caption)), Data.tex{end+1}=['\caption{' caption '}' ]; end;
        end
        Data.tex{end+1}=['\label{' label '}'];
        Data.tex{end+1}='\end{figure}';
        Data.tex{end+1}='\end{center}';
        Data.tex{end+1}=' ';
        Data.tex{end+1}=' ';
        if  strcmp(Data.style, 'beamer'), Data.tex{end+1}='\end{frame} '; end
        writeLatexFile();
        
    end

    function addSubFigure(H_v,width)
        
        fig_num=[];
        
        for i=1:length(H_v)
            Data.figure_number=1;
            
            while(exist([ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ],'file'))
                Data.figure_number=Data.figure_number+1;
            end
            
            fig_num(end+1)=Data.figure_number;
            
            
            LocalFig2eps(H_v(i),[ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ]);
         %   saveas(H_v(i),[ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.fig' ], 'fig');
            
            
        end
        
        Data.tex=[];
        Data.tex{end+1}=' ';
        Data.tex{end+1}='\begin{center}';
        Data.tex{end+1}='\begin{figure}';
        Data.tex{end+1}='\caption{}' ;
        Data.tex{end+1}='\label{}' ;
        Data.tex{end+1}='\centering';
        for i=1:length(H_v)
            Data.tex{end+1}=['\subfigure[]{\includegraphics[width=\textwidth,height=0.8\textheight,keepaspectratio]{./figures/Fig' num2str(fig_num(i)) '.pdf}}']; % [width=' width ']
        end
        Data.tex{end+1}='\end{figure}';
        Data.tex{end+1}='\end{center}';
        Data.tex{end+1}=' ';
        Data.tex{end+1}=' ';
        writeLatexFile();
        
    end

    function addTable(varargin)
        
        
        precision=str2num(CONFIG.matPrecision); % default precision
        legend=[];
        caption=[];
        multipage = 0;
        landscape=0;
        fontSize='';
        bold=[];
        label = [];
        nbFactors = 0;
        Mat_m=varargin{1}; % La matrice
        [nb_ligne,nb_colone]=size(Mat_m);
        
        % ----------------------------------------------------------------
        % get arg
        arg=struct(varargin{2:end});
        if nargin>=2
            if ( isfield(arg,'precision')), precision=arg.precision;  end;
            if ( isfield(arg,'legend')), legend=arg.legend;  end;
            if ( isfield(arg,'caption')), caption=arg.caption;  end;
            if ( isfield(arg,'bold')), bold=arg.bold; end;
            if ( isfield(arg,'multipage')), multipage=arg.multipage; end;
            if ( isfield(arg,'landscape')), landscape=arg.landscape; end;
            if ( isfield(arg,'label')), label=arg.label; end;
            if ( isfield(arg,'fontSize')), fontSize=arg.fontSize; end;
            if ( isfield(arg,'nbFactors')), nbFactors=arg.nbFactors; end;
        end
        
        % ----------------------------------------------------------------
        % Checking
        if ( nargin == 0 )
            disp(['LatexCreator::addTable() : Not enough input arguments. ' ])
            return
        end
        
        if (length(legend) ~= nb_colone && ~isempty(legend) )
            disp(['LatexCreator::addTable() : legend size dimension mismatch ' ])
            disp(['LatexCreator::addTable() : the table was not added. ' ])
            return
        end
        
        
        if (iscell(Mat_m))
            Mat_c=Mat_m;
        elseif(isnumeric(Mat_m))
            Mat_c=mat2cell(Mat_m,ones(1,nb_ligne),ones(1,nb_colone));
        else
            disp(['LatexCreator::addTable() : this function only works with double or cell matrix. ' ])
            disp(['LatexCreator::addTable() : the table was not added. ' ])
            return
        end
        
        if multipage && nb_ligne>multipage
            nbTables = ceil((nb_ligne-1)/multipage);
            for k=1:nbTables
                ind = 1+(k-1)*multipage+1:min(k*multipage, nb_ligne);
                Mat = Mat_c([1 ind], :);
                %                 [int, ib] = intersect(bold(:, 1), ind);
                %                 if ~isempty(int)
                %                     kBold = bold(ib, :);
                %                     kBold(:, 1) = kBold(:, 1)-ind(1)+2;
                %                 else
                %                     kBold = [];
                %                 end
                addTable(Mat, 'bold', [], 'legend', legend, 'caption', caption);
            end
            return
        end
        % ----------------------------------------------------------------
        % convertion en str
        
        for i=1:nb_ligne
            for j=1:nb_colone
                if(isnumeric(Mat_c{i,j}))
                    Mat_c{i,j}=num2str(Mat_c{i,j},precision);
                    %                     Mat_c{i,j}=sprintf(['%6.',sprintf('%d',precision),'f'],Mat_c{i,j});
                end
            end
        end
        
        % Table Header
        Data.tex=[];
        if ~isempty(caption)
        % slide header
        if  strcmp(Data.style, 'beamer')
            Data.tex{end+1}=['\begin{frame}\frametitle{' caption '}'];
        end
        
        %%-------------------------------------------------
        Data.tex{end+1}=' ';
        if landscape
            Data.tex{end+1}='\begin{sidewaystable}';
        else
            Data.tex{end+1}='\begin{table}';
        end
        Data.tex{end+1}='\begin{center}';
        Data.tex{end+1}=['\' fontSize];
       Data.tex{end+1}=' \setlength{\tabcolsep}{.16667em}'; 
        end
        tmp_line='\begin{tabular}{';
        
        for pos_c =1 : nb_colone,
            if pos_c<=nbFactors
                tmp_line=[tmp_line 'l'];
            else
                tmp_line=[tmp_line 'c'];
            end
        end
        
        tmp_line=[tmp_line '}'];
        Data.tex{end+1}=tmp_line;
        
        
        %%-------------------------------------------------
        % Legend
        
        if (~isempty(legend))
            %           Data.tex{end+1}='\hline';
            tmp_line=legend{1};
            for pos_c =2 : nb_colone,
                tmp_line=[tmp_line ' & ' legend{pos_c}];
            end
            tmp_line=[tmp_line ' \\'];
            Data.tex{end+1}=tmp_line;
            %          Data.tex{end+1}='\hline';
        end
        
        %%-------------------------------------------------
        % Table
        
        %      Data.tex{end+1}='\hline';
        
        for pos_l=1:nb_ligne
            tmp_line=Mat_c{pos_l,1};
            
            for pos_c = 2 : nb_colone
                if ~isempty(bold)  && sum(pos_l == bold(:, 1)) && sum(pos_c == bold(:, 2))
                    tmp_line=[  tmp_line  ' & \textbf{' Mat_c{pos_l,pos_c} '}'];
                else
                    tmp_line=[  tmp_line  ' & ' Mat_c{pos_l,pos_c} ];
                end
            end
            
            Data.tex{end+1} = [ tmp_line ' \\' ];
            if pos_l==1,          Data.tex{end+1}='\hline'; end
            
        end
        
        Data.tex{end+1}='\end{tabular}';
        if ~isempty(caption)
        
        Data.tex{end+1}='\end{center}';
        if ~ strcmp(Data.style, 'beamer')
            Data.tex{end+1}=['\caption{' caption '}' ];
        end
        Data.tex{end+1}=['\label{' label '}'];
        
        if landscape
            Data.tex{end+1}='\end{sidewaystable}';
        else
            Data.tex{end+1}='\end{table}';
        end
        
        Data.tex{end+1}='';
        if  strcmp(Data.style, 'beamer'), Data.tex{end+1}='\end{frame} '; end
        end
        writeLatexFile();
        
        
    end % END addTable

    function addTextFile(filein)
        
        
        
        TEX=textread(filein,'%s','delimiter','\n');
        
        for pos=1:length(TEX),
            if strfind(TEX{pos}, '\lstinputlisting') && ~(strfind(TEX{pos}, '../..') || strfind(TEX{pos}, '..\..'))
                TEX{pos} = strrep(TEX{pos}, '{../', '{../../');
                TEX{pos} = strrep(TEX{pos}, '{..\', '{..\..\');
            end
            
            res=strfind(TEX{pos},'\end{Verbatim}');
            
            if (~isempty(res))
                TEX{pos}(res)='|';
            end
        end
        
        Data.TEX = TEX;
        
        
        Data.tex=[];
        Data.tex{end+1}=' ';
        Data.tex{end+1}='\begin{Verbatim}[fontsize=\scriptsize,frame=single]';
        Data.tex{end+1}=' ';
        
        
        for pos = 1: length(TEX)
            
            Data.tex{end+1}=TEX{pos};
            
        end
        
        Data.tex{end+1}=' ';
        Data.tex{end+1}='\end{Verbatim}';
        Data.tex{end+1}=' ';
        writeLatexFile();
    end

    function addInput(input)
        Data.tex=[];
        Data.tex{end+1}=' ';
        Data.tex{end+1}=['\input{' input '}'];
        Data.tex{end+1}=' ';
        writeLatexFile();
    end

    function newPage()
        Data.tex=[];
        Data.tex{end+1}=' ';
        Data.tex{end+1}='\newpage';
        Data.tex{end+1}=' ';
        writeLatexFile();
    end

    function addLine(line)
        Data.tex=[];
        Data.tex{end+1}=' ';
        Data.tex{end+1}=line;
        Data.tex{end+1}=' ';
        writeLatexFile();
    end

    function deleteLastFig(varargin)
        
        if(nargin==0)
            
            if(Data.figure_number==0)
                warning('Pas de nouvelle figure a effacer')
                return
            else
                
                answer=input(['remove ' Data.Dir '/figures/Fig' num2str(Data.figure_number) '  (y/n) \n'],'s');
                if(answer=='y')
                    disp(['removing ' Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ]);
                    delete([ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.pdf' ]);
                    disp(['removing ' Data.Dir '/figures/Fig' num2str(Data.figure_number) '.fig' ]);
                    delete([ Data.Dir '/figures/Fig' num2str(Data.figure_number) '.fig' ]);
                end
                
            end
            
        else
            
            fig_no=varargin{1};
            
            answer=input(['removing ' Data.Dir '/figures/Fig' num2str(fig_no) '  (y/n)'],'s');
            if(answer=='y')
                
                disp(['removing ' Data.Dir '/figures/Fig' num2str(fig_no) '.pdf' ]);
                delete([ Data.Dir '/figures/Fig' num2str(fig_no) '.pdf' ]);
                
                disp(['removing ' Data.Dir '/figures/Fig' num2str(fig_no) '.fig' ]);
                delete([ Data.Dir '/figures/Fig' num2str(fig_no) '.fig' ]);
                
            end
        end
        
        Data.figure_number=0;
        
    end

end % END LatexCreator



function Data=FastEPSResize(epsfile,Position_pts_v)





%% openning
try
    fid=fopen(epsfile,'rb');
catch
    return
end


%% reading
Data=fread(fid,'*char')';




%% Finding & Replacing BoundingBox

str_replace=['BoundingBox: ',num2str(Position_pts_v(1),3),' ',num2str(Position_pts_v(2),3),' ',num2str(Position_pts_v(3),3),' ',num2str(Position_pts_v(4),3)];

id=findstr('BoundingBox:',Data);

for i=1:length(id)
    str=strtok(Data(id(i):end),10);
    
    
    %% atend ?
    
    res_atend=findstr('atend',str);
    
    if(isempty(res_atend)) % si on est pas dans le cas at end
        
        Lrpl=length(str_replace);
        Lstr=length(str);
        
        if(Lstr<Lrpl)
            warning('str length error');
            return
        end
        
        str(1:Lrpl)=str_replace;
        str(Lrpl+1:end)=char(str(Lrpl+1:end)*0+32);
        
        Data(id(i):id(i)+Lstr-1)=str;
        
        
    end
    
end

%% Finding & Replacing PageBoundingBox

str_replace=['PageBoundingBox: ',num2str(Position_pts_v(1),3),' ',num2str(Position_pts_v(2),3),' ',num2str(Position_pts_v(3),3),' ',num2str(Position_pts_v(4),3)];

id=findstr('PageBoundingBox:',Data);

for i=1:length(id)
    str=strtok(Data(id(i):end),10);
    
    
    %% atend ?
    
    res_atend=findstr('atend',str);
    
    if(isempty(res_atend)) % si on est pas dans le cas at end
        
        Lrpl=length(str_replace);
        Lstr=length(str);
        
        if(Lstr<Lrpl)
            warning('str length error')
            return
        end
        
        str(1:Lrpl)=str_replace;
        str(Lrpl+1:end)=char(str(Lrpl+1:end)*0+32);
        
        Data(id(i):id(i)+Lstr-1)=str;
        
        
    end
    
end

%% writing



fclose(fid);

fid=fopen(epsfile,'wb');

fwrite(fid,Data,'char');

fclose(fid);



end

function setWindowOnTop(h,state)
% SETWINDOWONTOP sets a figures Always On Top state on or off
%
%  Copyright (C) 2006  Matt Whitaker
%
%  This program is free software; you can redistribute it and/or modify it
%  under
%   the terms of the GNU General Public License as published by the Free
%   Software Foundation; either version 2 of the License, or (at your
%   option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%  General Public License for more details.
%
% SETWINDOWONTOP(H,STATE): H is figure handle or a vector of figure handles
%                          STATE is a string or cell array of strings-
%                               'true' - set figure to be always on top
%                               'false' - set figure to normal
%                           if STATE is a string the state is applied to
%                           all H. If state is a cell array the length STATE
%                           must equal that of H and each state is applied
%                           individually.
%  Examples:
%   h= figure;
%   s = 'true';
%   setWindowOnTop(h,s) %sets h to be on top
%
%   h(1) = figure;
%   h(2) = figure;
%   s = 'true';
%   setWindowOnTop(h,s) %sets both figures to  be on top
%
%   h(1) = figure;
%   h(2) = figure;
%   s = {'true','false'};
%   setWindowOnTop(h,s) %sets h(1) on top, h(2) normal
% Notes:
% 1. Figures must have 'Visible' set to 'on' and not be docked for
%    setWindowOnTop to work.
% 2. Routine does not work for releases prior to R14SP2
% 3. The Java calls are undocumented by Mathworks
%
% Revisions: 09/28/06- Corrected call to warning and uopdated for R2006b


warning on
drawnow; %need to make sure that the figures have been rendered or Java error can occur

%check input argument number
error(nargchk(2, 2, nargin, 'struct'));

%is JVM available
if ~usejava('jvm')
    error('setWindowOnTop requires Java to run.');
end
j=[];
s=[];
[j,s] = parseInput;
if(isempty(j)||isempty(s))
    return
end
setOnTop; %set the on top state

    function [j,s] = parseInput
        % is h all figure handles
        if ~all(ishandle(h)) || ~isequal(length(h),length(findobj(h,'flat','Type','figure')))
            warning('All input handles must be valid figure handles');
            return
        end %if
        
        %handle state argument
        if ischar(state)
            %make it a cell
            s = cellstr(repmat(state,[length(h),1]));
            
        elseif iscellstr(state)
            if length(state) ~= length(h)
                warning('Cell array of strings: state must be same length as figure handle input');
                return
            end %if
            s = state;
        else
            warning('state must be a character array or a cell array of strings');
            return
        end %if
        
        %check that the states are all valid
        if ~all(ismember(s,{'true','false'}))
            warning('Invalid states entered')
            return
        end %if
        
        if length(h) == 1
            j{1} = get(h,'javaframe');
        else
            j = get(h,'javaframe');
        end %if
        
    end %parseInput

    function setOnTop
        
        %get version so we know which method to call
        v = ver('matlab');
        %anticipating here that Mathworks will continue to change these
        %undocumented calls
        switch v(1).Release
            case {'(R14SP2)','(R14SP3)'}
                on_top = 1;
            case {'(R2006a)','(R2006b)','(R2007a)','(R2007b)','(R2008b)'}
                on_top = 2;
            otherwise %warn but try method 2
                warning('setWindowOnTop:UntestedVersion',['setWindowOnTop has not been tested with release: ',v.Release]);
                on_top = 2;
                return
                
        end %switch
        for i = 1:length(j)
            switch on_top
                case 1  %R14SP2-3
                    w = j{i}.fClientProxy.getFrameProxy.getClientFrame;
                case 2 %R2006a+
                    w= j{i}.fFigureClient.getWindow;
                otherwise %should not happen
                    warning('Invalid on top method');
                    return
            end %switch
            awtinvoke(w,'setAlwaysOnTop',s{i});
        end %for j
    end %setOnTop
warning on
end %setWindowOnTop


function res=set_LatexCreatorConfig(key_query,query_value)

res=0;
ho=getenv('HOME');

cfg_fn=[ho,'/.LatexToolBar/config.cfg'];

if(~exist(cfg_fn,'file'))
    fid=fopen(cfg_fn,'w');
    fclose(fid);
end


% arguments tests:
if(~ischar(key_query) | ~ischar(query_value) | isempty(key_query)|isempty(query_value))
    
    error('Arg error');
    
end

% ------------------------------------------------
% Reading file
key=[];
value=[];

if(exist(cfg_fn,'file'))
    
    str=textread(cfg_fn,'%s','delimiter','\n');
    for i=1:length(str)
        
        splited_str=strread(str{i},'%s');
        if(length(splited_str)>=2)
            key{end+1}= splited_str{1};
            value{end+1}=splited_str{2};
            for j=3:length(splited_str)
                value{end}=[value{end},' ',splited_str{j}];
            end
        end
    end
    
end

%--------------------------------
% query processing



key_no=strmatch(key_query,key);

if(isempty(key_no))
    
    key{end+1}=key_query;
    value{end+1}=query_value;
else
    value{key_no}=num2str(query_value);
end


fid=fopen(cfg_fn,'wt');

if(fid==-1)
    res=-1;
    return
end


for i=1:length(key)
    fprintf(fid,'%s %s\n',key{i},value{i});
end
fclose(fid);






end

function Out=get_LatexCreatorConfig(key_query)


Out=[];

ho=getenv('HOME');
cfg_fn=[ho,'/.LatexToolBar/config.cfg'];

if(~exist(cfg_fn,'file'))
    Out.viewer = 'open -a Preview';
    Out.ref_dir = '~/papers/reports';
    Out.YPosition = 1.269;
    Out.FigureWidth = 120;
    Out.FigureFontSize = 14;
    Out.editor = 'matlab';
    Out.LastTexFile =  '/Users/lagrange/svn/ircam/papers/reports//bofCasa.tex';
    Out.matPrecision = '3';
    return
end

% ------------------------------------------------
% Reading file
key=[];
value=[];

if(~exist('cfg_fn','var'))
    cfg_fn=which('LatexCreator.cfg');
end

str=textread(cfg_fn,'%s','delimiter','\n');
for i=1:length(str)
    
    splited_str=strread(str{i},'%s');
    if(length(splited_str)>=2)
        key{end+1}= splited_str{1};
        value{end+1}=splited_str{2};
        for j=3:length(splited_str)
            value{end}=[value{end},' ',splited_str{j}];
        end
    end
end



if(isempty(key_query)) % then return a structure with all parameters
    
    Out=struct;
    for i=1:length(key)
        
        Out=setfield(Out,key{i},value{i});
        
    end
    
    return;
else% return the query result
    
    
    key_no=strmatch(key_query,key);
    
    if(isempty(key_no))
        %warning(['no field : ',key_query,' in ',cfg_fn]);
        Out=[];
        
    else
        
        Out=value{key_no};
        
    end
    
    
    
end

end
