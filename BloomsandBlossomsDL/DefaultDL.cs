﻿using BloomsandBlossomsCL;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace BloomsandBlossomsDL
{
    public class DefaultDL
    {
        private ECGroupConnection _myConnection = new ECGroupConnection();
        #region constructor
        public DefaultDL()
        {

        }
        #endregion
        #region public variables
        public int CategoryID { get; set; }
        public string CategoryName { get; set; }
        public string PageName { get; set; }
       
        #endregion
        public DataSet GetCategoryDetails()
        {
            DataSet ds = new DataSet();
            try
            {
                Database db = DatabaseFactory.CreateDatabase(_myConnection.DatabaseName);
                DbCommand dbCommand = db.GetStoredProcCommand("spGetCategoryList");
                dbCommand.Parameters.Clear();
                dbCommand.CommandTimeout = 300;
                ds = db.ExecuteDataSet(dbCommand);                

            }
            catch (Exception ex)
            {
                ErrorLog.LogErrorMessageToDB("", "DefaultDL.cs", "GetCategoryDetails", ex.Message.ToString(), _myConnection);
                throw;
            }
            return ds;
        }
        public DataSet GetTop5Products()
        {
            DataSet ds = new DataSet();
            try
            {
                Database db = DatabaseFactory.CreateDatabase(_myConnection.DatabaseName);
                DbCommand dbCommand = db.GetStoredProcCommand("spGetTopProductInfo");
                dbCommand.Parameters.Clear();
                dbCommand.CommandTimeout = 300;
                ds = db.ExecuteDataSet(dbCommand);
            }
            catch (Exception ex)
            {
                ErrorLog.LogErrorMessageToDB("", "DefaultDL.cs", "GetTop5Products", ex.Message.ToString(), _myConnection);
                throw;
            }
            return ds;
        }
    }
}
