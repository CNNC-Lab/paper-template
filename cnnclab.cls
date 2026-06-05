%% cnnclab.cls — CNNC-Lab manuscript class
%% Derived from the Henriques Lab LaTeX template (MIT). See LICENSE.
%% Single-column, clean typography, publication-lifecycle aware.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cnnclab}[2026/06/05 v0.1 CNNC-Lab manuscript class]

%% ---------------------------------------------------------------------------
%% Options
%% ---------------------------------------------------------------------------
\newif\if@cnnc@submission \@cnnc@submissionfalse
\newif\if@cnnc@review     \@cnnc@reviewfalse
\newif\if@cnnc@finalmode  \@cnnc@finalmodefalse
\newif\if@cnnc@draftmode  \@cnnc@draftmodefalse
\newif\if@cnnc@endfloat   \@cnnc@endfloatfalse
\newif\if@cnnc@lineno     \@cnnc@linenofalse

\DeclareOption{submission}{%
  \@cnnc@submissiontrue \@cnnc@endfloattrue \@cnnc@linenotrue}
\DeclareOption{review}{\@cnnc@reviewtrue}
\DeclareOption{final}{\@cnnc@finalmodetrue}
\DeclareOption{draft}{\@cnnc@draftmodetrue}
\DeclareOption{endfloat}{\@cnnc@endfloattrue}
\DeclareOption{lineno}{\@cnnc@linenotrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{}
\ProcessOptions\relax

\LoadClass[11pt,a4paper]{article}

%% ---------------------------------------------------------------------------
%% Core packages (all in a standard TeX Live full install)
%% ---------------------------------------------------------------------------
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
\RequirePackage[a4paper,margin=2.5cm]{geometry}
\RequirePackage{setspace}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{amsmath,amssymb}
\RequirePackage{booktabs}
\RequirePackage{microtype}
\RequirePackage[colorlinks=true,allcolors=blue!55!black]{hyperref}
\RequirePackage[capitalise,nameinlink]{cleveref}

%% Bibliography: biblatex + biber
\RequirePackage[backend=biber,style=numeric-comp,sorting=none,maxbibnames=99,giveninits=true]{biblatex}

%% Brand colors
\definecolor{cnncaccent}{HTML}{1F6FB2}
\definecolor{cnncmuted}{HTML}{555555}

%% ---------------------------------------------------------------------------
%% Mode-dependent setup
%% ---------------------------------------------------------------------------
\if@cnnc@lineno
  \RequirePackage[switch,mathlines]{lineno}
  \AtBeginDocument{\linenumbers}
\fi

\if@cnnc@endfloat
  \RequirePackage[nomarkers,nolists,tablesfirst]{endfloat}
\fi

\if@cnnc@submission
  \doublespacing
\else
  \onehalfspacing
\fi
\if@cnnc@finalmode
  \singlespacing
\fi

% Tracked changes: only active in [review]; stripped otherwise / in [final].
\if@cnnc@review
  \RequirePackage[markup=underlined]{changes}
\else
  % no-op stubs so a [review]-authored source still compiles in other modes
  \providecommand{\added}[1]{#1}
  \providecommand{\deleted}[1]{}
  \providecommand{\replaced}[2]{#1}
\fi
\if@cnnc@finalmode
  \PassOptionsToPackage{final}{changes}
\fi

% Working notes: visible only in draft mode.
\if@cnnc@draftmode
  \RequirePackage[textsize=footnotesize]{todonotes}
\else
  \RequirePackage[disable]{todonotes}
\fi

%% ---------------------------------------------------------------------------
%% Title block
%% ---------------------------------------------------------------------------
\newcommand{\@cnnc@corresponding}{}
\newcommand{\corresponding}[1]{\renewcommand{\@cnnc@corresponding}{#1}}
\newcommand{\@cnnc@keywords}{}
\newcommand{\keywords}[1]{\renewcommand{\@cnnc@keywords}{#1}}
\newcommand{\@cnnc@runninghead}{}
\newcommand{\runninghead}[1]{\renewcommand{\@cnnc@runninghead}{#1}}

\renewcommand{\maketitle}{%
  \begingroup
  \raggedright
  {\LARGE\bfseries\color{cnncaccent}\@title\par}
  \vskip 1ex
  {\large\@author\par}
  \vskip 0.5ex
  \ifx\@cnnc@corresponding\@empty\else
    {\color{cnncmuted}\small Correspondence: \texttt{\@cnnc@corresponding}\par}\fi
  \ifx\@cnnc@keywords\@empty\else
    {\color{cnncmuted}\small\textbf{Keywords:} \@cnnc@keywords\par}\fi
  \endgroup
  \vskip 2ex\hrule\vskip 2ex}

%% ---------------------------------------------------------------------------
%% Variant-aware section input
%% Looks for variants/<ACTIVEJOURNAL>/<name>.tex first, else sections/<name>.tex
%% ---------------------------------------------------------------------------
\providecommand{\ACTIVEJOURNAL}{}
\newcommand{\sectioninput}[1]{%
  \edef\@cnnc@vpath{variants/\ACTIVEJOURNAL/#1.tex}%
  \IfFileExists{\@cnnc@vpath}{\input{\@cnnc@vpath}}{\input{sections/#1.tex}}}

%% ---------------------------------------------------------------------------
%% Abstract styling
%% ---------------------------------------------------------------------------
\renewenvironment{abstract}{%
  \vskip 1ex\noindent{\bfseries\color{cnncaccent}Abstract}\par\nobreak\vskip 0.5ex
  \begingroup\small\setlength{\parindent}{0pt}}%
  {\par\endgroup\vskip 1ex\hrule\vskip 2ex}

\endinput
