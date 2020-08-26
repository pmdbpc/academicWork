%
% Project Title: Q-Learning based Intelligent Soccer Player
% Program Author: Parth M. Desai.
% Course: Adaptive Critic Design.
% Last Modified: 09-MAY-2015
%
function agent1()
    %
    % -------------------------------------------------------------------
    % ------------------------- TEAM DEFINITION -------------------------
    % ----------- (Change the following values as required.) ------------
    teamname = 'Q-Learning';
    myUnum = 1;
    serverHost = '127.0.0.1';
    serverPort = 5050;
    % 
    % -------------------------------------------------------------------
    % ------------- (Leave the rest of the Function as is.) -------------
    %
    jarpath = 'gsjar/JavaSampleClient.jar';
    javaaddpath(jarpath);
    me = jsampleclient.ManualClient(serverHost, serverPort, teamname, myUnum);
    fprintf('Starting player...');
    %
    % -------------------------------------------------------------------
    % -------------------- GLOBAL VARIABLE DEFINITION -------------------
    %
    Epsilon = 0.999;        % Initialize Epsilon for Action selection policy.
    Update_Eps = 0;         % Initialize Update Rate for Epsilon
    Discount_Factor = 0.3;  % Determines Effect of Future Values on Current 
                            % Value update. (0 < ? < 1)
    Learning_Rate = 0.05;    % Determines the speed of Learning. (0 < ? < 1)
    My_Prev_Row = 0;        % Buffer to Store last state information.
    My_Prev_Col = 0;        % Buffer to Store last state information.
    My_Prev_Act = 0;        % Buffer to Store last action information.
    Last_Own_Ball = 0;      % Buffer to Store last owner of the ball.
    Op_Prev_Row = 0;        % Buffer to Store opponent last state information.
    Op_Prev_Col = 0;        % Buffer to Store oponnent last state information.
    Prev_Dist = 0;          % Buffer to Store last distance between player and opponent.
    Curr_Dist = 0;          % Buffer to Store current distance between player and opponent.
    Max_Act_Q_Val = 0;      % Initialize the Maximum Q value at any state.
    Prev_Ball_Owner = 0;    % Buffer to Store ball ownership in previous round.
    Prev_Rel_Row = 0;       % Buffer to store relative row of target (goal / opponent) from player.
    Prev_Rel_Col =0;        % Buffer to store relative column of target (goal / opponent) from player.
    %
    % --- Define number of actions an agent can take
    Actions = 4;    % (North - East - South - West)
    % Actions = 8;  % (North - NorthEast - East - SouthEast - South - 
    % SouthWest - West - NorthWest)
    %
    % --- Other Variables.
    Ball_Ownership = 2;     % Number of Ball Owners.
   	Limit = 0;              % To hold the minimum Epsilon value to 0.1.
    Game = 1;               % Record Number of Games Played.
    Map(:,1) = zeros;       % Array to store Game History.
    Steps(:,1) = zeros;     % Array to store History of no. of Steps to complete a game.
    My_Old_Score = 0;       % Buffer to store Own Score uptil last game.
    Your_Old_Score = 0;     % Buffer to store Opponent Score uptil last game.
    New_Game = 1;           % Flag to indicate new game started.
    Count = 2;              % Buffer Game counts for Win probability calculation.
    Record(:,1) = zeros;    % Array to store Agent Wins every 100 games.
    %
    % -------------------------------------------------------------------
    % ----- AGENT AND ENVIRONMENT CLASS INITIALIZATION INFORMATION ------
    %
    theAgent = Agent();
    theEnv = Env();
    theEnv = theEnv.Update(me);
    Field_Rows = theEnv.Rows;
    Field_Cols = theEnv.Cols;
    Max_Q_Rows = (2*Field_Rows) - 1;
    Max_Q_Cols = (2*Field_Cols) - 1;
    %
    % -------------------------------------------------------------------
    % --------------------- INITIALIZE Q - TABLE ------------------------
    %
    Q = zeros(Ball_Ownership,Max_Q_Rows,Max_Q_Cols,Actions);
    %
    % -------------------------------------------------------------------
    % -------------------------- START PLAYER ---------------------------
    %
    while (me.getIsNotGameStopped())
        if(me.UpdateFromServer())
            if(me.getIsGameStarted())
                theAgent = theAgent.Update(me);
                me.SendAction(me.StringActionToSoccerAction(Think(theAgent, theEnv)));
            end
        end
    end
    %
    % -------------------------------------------------------------------
    % ------------------------- PLOTTING CURVES -------------------------
    %
    figure; plot(Map);      % Q-Learning Agent: Wins and Losses.
    xlim([0 30000]); ylim([0 15000]);
    title('Q-Learning Agent: Wins and Losses');
    xlabel('Game Number'); ylabel('Wins (Increment) and Loss (Horizontal)');
    figure; plot(Steps);    % Q-Learning Agent: Number of Steps per Game.
    xlim([0 30000]);
    title('Q-Learning Agent: Number of Steps per Game');
    xlabel('Game Number'); ylabel('Steps per Game');
    figure; plot(Record);   % Q-Learning Agent: Probability of Game Wins (per 100 Games)
    xlim([0 300]); ylim([0 1]);
    title('Q-Learning Agent: Probability of Game Wins (Measured per 100 Games)');
    xlabel('Game Number (Multiples of 100)'); ylabel('Game Win Probability)');
    %
    % -------------------------------------------------------------------
    % --------------------------- END PLAYER ----------------------------
    %
    fprintf('Stopping player and clearing resources.');
    me.OnGameStopped();
    %
    clear me
    javarmpath(jarpath);
    %
    % -------------------------------------------------------------------
    % -------------------------------------------------------------------
    % ------------------ AGENT INTELLIGENCE FUNCTION --------------------
    %
    function act = Think(agent, env)
        % ---------------------------------------------------------------
        % --------------- Obtain Environment Information ----------------
        % ---------------------------------------------------------------
        % Other Options (env.PassDistance, env.VisibilityDistance, 
        % env.GoalWidth, env.MinPlayers, env.MaxPlayers, env.MySide, 
        % env.MyTeamName, env.MyUnum)
        %
        Field_Row = env.Rows;
        Field_Col = env.Cols;
        Goal_Up_Lim = env.GoalUpperRow;
        Goal_Low_Lim = env.GoalLowerRow;
        % ---------------------------------------------------------------
        % ----------------- Obtain Player Information -------------------
        % ---------------------------------------------------------------
        % Other Options (agent.TeamMatesRow, agent.TeamMatesCol,
        % agent.TeamMatesUnum, agent.OpponentsUnum, agent.LastSeeBall, 
        % agent.AreWeBallOwner, agent.BallRow, agent.BallCol)
        %
        Round = agent.Cycle;
        My_Row = agent.MyRow;
        My_Col = agent.MyCol;
        Op_Row = agent.OpponentsRow;
        Op_Col = agent.OpponentsCol;
        They_Own_Ball = agent.AreTheyBallOwner;
        I_Own_Ball = agent.AmIBallOwner;
        My_Score = agent.OurScore;
        Your_Score = agent.OppScore;
        % ---------------------------------------------------------------
        % ----------------- Obtain Action Information -------------------
        % ------- (Changing datatype to be useful for the code) ---------
        % Other Options (Commands.GoNorthEast, Commands.GoSouthEast,
        % Commands.GoSouthWest, Commands.GoNorthWest, Commands.Hold)
        %
        North = str2double(Commands.GoNorth);
        South = str2double(Commands.GoSouth);
        East = str2double(Commands.GoEast);
        West = str2double(Commands.GoWest);
        % 
        % ---------------------------------------------------------------
        % ---------------------- Mapping Game Data. ---------------------
        % ---------------------------------------------------------------
        if (((My_Score - My_Old_Score) == 1) || ((Your_Score - Your_Old_Score) == 1))
            Map(Game,1) = My_Score;
            Game = Game + 1;
            Steps(Game,1) = 1;
            New_Game = 1;
        else
            New_Game = 0;
        end
        % --- Record steps per game.
        if ((My_Score - My_Old_Score) == 0)
            Steps(Game,1) = Steps(Game,1) + 1;
        end
        % --- Record Game win probability every 100 games.
        if ((rem(Game,100) == 0) && New_Game == 1)
            Record(Count,1) = My_Score/Game;
            Count = Count + 1;
        end
        %
        % ---------------------------------------------------------------
        % ----------------- Q-Table State Determination -----------------
        % ---------------------------------------------------------------
        % --- Determine Relative Position of Opponent / Goal from the
        % --- Q-learning agent's current position.
        Ball_Owner = 0;
        if (I_Own_Ball)
            Ball_Owner = 1;
            if ((My_Row - Goal_Up_Lim) < 1)
                Rel_Row = Field_Row + (My_Row - Goal_Up_Lim);
                Rel_Col = Field_Col + (My_Col - Field_Col);
            elseif ((My_Row - Goal_Up_Lim) >= 1)
                Rel_Row = Field_Row + (My_Row - Goal_Low_Lim);
                Rel_Col = Field_Col + (My_Col - Field_Col);
            end
        elseif (They_Own_Ball)
            Ball_Owner = 2;
            Rel_Row = Field_Row + (My_Row - Op_Row);
            Rel_Col = Field_Col + (My_Col - Op_Col);
        end
        %
        % ---------------------------------------------------------------
        % ---------------- Current State Action Selection ---------------
        % ---------------------------------------------------------------
        Act_Select = rand;
        if (Act_Select <= Epsilon)
            % -----------------------------------------------------------
            % --- Exploration Condition. --------------------------------
            r = rand;
            if r < 0.25
                action = East;
            elseif r < 0.5
                action = West;
            elseif r < 0.75
                action = South;
            elseif r < 1
                action = North;
            end
        elseif (Act_Select > Epsilon)
            % -----------------------------------------------------------
            % --- Exploitation Condition. -------------------------------
            Max_Act_Val = -100;
            for try_act = 1:Actions
                Obtain_Q = Q(Ball_Owner,Rel_Row,Rel_Col,try_act);
                if (Max_Act_Val < Obtain_Q)
                    % --- Find Best Action. -----------------------------
                    Max_Act_Val = Obtain_Q;
                    Best_Act = try_act;
                end           
            end
            action = Best_Act;
        end
        %
        % ---------------------------------------------------------------
        % ---------------------- Q - Table Updation ---------------------
        % ---------------------------------------------------------------
        if (Round ~= 0)
            % --- Euclidean Distance between player and opponent.
            if (I_Own_Ball)
                if ((My_Row - Goal_Up_Lim) < 1)
                    Curr_Dist = (abs(My_Row - Goal_Up_Lim)) + (abs(My_Col - Field_Col));
                elseif ((My_Row - Goal_Up_Lim) >= 1)
                    Curr_Dist = (abs(My_Row - Goal_Low_Lim)) + (abs(My_Col - Field_Col));
                end
            elseif (They_Own_Ball)
                Curr_Dist = (abs(Op_Row - My_Row)) + (abs(Op_Col - My_Col));
            end
            % -----------------------------------------------------------
            % --- Rewards Calculation. ----------------------------------
            %
            if ((New_Game == 1) && (They_Own_Ball == 1) && ((My_Score - My_Old_Score) == 1) &&...
                ((My_Prev_Row == Goal_Up_Lim && My_Prev_Col == Field_Col && My_Prev_Act == East) || ...
                (My_Prev_Row == Goal_Low_Lim && My_Prev_Col == Field_Col && My_Prev_Act == East)))
                % --- Goal Reward. --------------------------------------
                Reward = 100;
            elseif (((My_Prev_Row == 1 && My_Prev_Col == 1 && (My_Prev_Act == North || My_Prev_Act == West)) || ...
                (My_Prev_Row == Field_Row && My_Prev_Col == 1 && (My_Prev_Act == South || My_Prev_Act == West)) || ...
                (My_Prev_Row == Field_Row && My_Prev_Col == Field_Col && (My_Prev_Act == South || My_Prev_Act == East)) || ...
                (My_Prev_Row == 1 && My_Prev_Col == Field_Col && (My_Prev_Act == North || My_Prev_Act == East)) || ...
                (My_Prev_Row == 1 && My_Prev_Act == North) || ...
                (My_Prev_Row == Field_Row && My_Prev_Act == South) || ...
                (My_Prev_Col == 1 && My_Prev_Act == West) || ...
                (My_Prev_Col == Field_Col && My_Prev_Act == East)))
                % --- Crossing Field Boundary Reward. -------------------
                Reward = -1;
            elseif ((Prev_Dist > Curr_Dist))
                Reward = 0.1;
            elseif ((They_Own_Ball == 1) && (Prev_Dist <= Curr_Dist))
                Reward = -1;
            else
                % --- Playing within Field Boundary Reward. -------------
                Reward = 0;
            end
            if ((Last_Own_Ball ~= I_Own_Ball))
                % --- Reward Reduction for losing ball ownership. -------
                Reward = Reward - 1;
            end
            % -----------------------------------------------------------
            % --- Q - Value Update of Previous State-Action pair. -------
            if (Act_Select <= Epsilon)
                % --- Determine Maximum Current State Q - Value ---------
                Max_Act_Q_Val = -100;
                for try_act = 1:Actions
                    Obtain_Q = Q(Ball_Owner,Rel_Row,Rel_Col,try_act);
                    if (Max_Act_Q_Val <= Obtain_Q)
                        Max_Act_Q_Val = Obtain_Q;
                    end
                end
            else
                Max_Act_Q_Val = Max_Act_Val;
            end
            % -----------------------------------------------------------
            % --- Q - Value Calculation. --------------------------------
            Q(Prev_Ball_Owner, Prev_Rel_Row, Prev_Rel_Col, My_Prev_Act) = Q(Prev_Ball_Owner, Prev_Rel_Row, Prev_Rel_Col, My_Prev_Act) + ...
                (Learning_Rate*(Reward + (Discount_Factor*(Max_Act_Q_Val)) - Q(Prev_Ball_Owner, Prev_Rel_Row, Prev_Rel_Col, My_Prev_Act)));
            %
        end
        %
        % ---------------------------------------------------------------
        % -------- Backing Up Current State - Action Iformation ---------
        % ---------------------------------------------------------------
        My_Prev_Row = My_Row;
        My_Prev_Col = My_Col;
        My_Prev_Act = action;
        Op_Prev_Row = Op_Row;
        Op_Prev_Col = Op_Col;
        Prev_Ball_Owner = Ball_Owner;
        Prev_Rel_Row = Rel_Row;
        Prev_Rel_Col = Rel_Col;
        Prev_Dist = Curr_Dist;
        My_Old_Score = My_Score;
        Your_Old_Score = Your_Score;
        if (I_Own_Ball == 1)
            Last_Own_Ball = 1;
        else
            Last_Own_Ball = 0;
        end  
        %
        % ---------------------------------------------------------------
        % --- Updating the Value of Epsilon to change Action Selection --
        % --- Policy from Exploration to Exploitation -------------------
        % ---------------------------------------------------------------
        Change_Time = (Field_Row * Field_Col * Actions);
        if (Epsilon <= 0.1)
            Limit = 1;
        end
        if ((Update_Eps == Change_Time) && (Limit ~= 1))
            % --- Reduce value of Epsilon by 0.001 After Number of Rounds
            % --- Equals "Change_Time" Variable.
            Epsilon = Epsilon - 0.001;
            Update_Eps = 0;
        elseif ((Update_Eps == Change_Time) && (Limit == 1))
            % --- After Epsilon = 0.1, Reduce value of Epsilon by 10% 
            % --- After same number of rounds as before.
            Epsilon = 0.9*Epsilon;
            Update_Eps = 0;
        else
            Update_Eps = Update_Eps + 1;
        end
        %
        % -------------------------------------------------------------------
        % ----------- Changing Datatype of action to be sent. ---------------
        % -------------------------------------------------------------------
        act = int2str(action);
        % -------------------------------------------------------------------
    end
end
