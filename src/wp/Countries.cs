using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

    internal class Countries
    {
        private static List<String> _trunked = new List<string>(new String[] { "33", "34", "44", "61", "64", "91", "353" });
        private static List<String> _nonTrunked = new List<string>(new String[] { "1" });

        /// <summary>
        /// Returns all trunked
        /// </summary>
        public static List<String> Trunked {
            get
            {
                return _trunked;
            }
        }
        
        /// <summary>
        /// Rerturns all non trunked
        /// </summary>
        public static List<String> NonTrunked
        {
            get
            {
                return _nonTrunked;
            }
        }

        public static int CalculateNonTrunkedFirstIndex(String countryCode, String number)
        {
            return (number.StartsWith(countryCode)) ? countryCode.Length : 0;
        }

        public static int CalculateTrunkedFirstIndex(String countryCode, String number)
        {
            if (number.StartsWith(countryCode)) return countryCode.Length;
            if (number.StartsWith("0")) return 1;
            return 0;
        }
    }
